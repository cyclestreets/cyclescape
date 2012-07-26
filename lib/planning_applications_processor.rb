class PlanningApplicationsProcessor

require 'net/http'
require 'tempfile'
require 'csv'

  def self.process_planning_applications
    processor = self.new
    processor.run
  end

  def run
    begin
      #fetch_zipfile
      #unzip_file
      process_csv
    ensure
      cleanup
    end
  end

  def fetch_zipfile
    # Ensure that we don't have the file in memory when downloading
    uri = URI("http://thunderflames.org/temp/planning_applications.zip")
    @tempfile = Tempfile.new('cyclekit-zip')
    @tempfile.binmode

    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new uri.request_uri

      http.request request do |response|
        response.read_body do |chunk|
          @tempfile.write chunk
        end
      end
    end
    @tempfile.close
  end

#   def process_csv
#     puts @tempfile.path
#     Zip::ZipInputStream::open(@tempfile.path) do |io|
#       io.get_next_entry
#       puts io.read
#       csv = CSV.new(io.read, headers: true)
#       csv.each do |row|
#         puts row.uid
#       end
#     end
#   end

#   def unzip_file
#     @csv_file = Tempfile.new('cyclekit-unzip')
#     @csv_file.binmode
# 
#     Zip::ZipFile::open(@tempfile.path) do |zipfile|
#       entry = zipfile.find_entry("planning_applications.head.csv")
#       zipfile.extract(entry, @csv_file.path)
#     end
#   end
  
#   def unzip_file
#     @csv_path = Tempfile.new('cyclekit-unzip').path
# 
#     puts @tempfile.path
#     Zip::ZipFile::open(@tempfile.path) do |zipfile|
#       entry = zipfile.find_entry("planning_applications.head.csv")
#       zipfile.extract(entry, @csv_path)
#     end
#   end

    def unzip_file
      @tempfile.open
      @csv_path = Tempfile.new('cyclekit-unzip').path
      system("unzip -p #{@tempfile.path} > #{@csv_path}")
    end

#   def unzip_file
#     csv_path = Tempfile.new('cyclekit-unzip').path
#     
#     @csv_file.binmode
# 
#     Zip::ZipInputStream::open(@tempfile.path) do |io|
#       entry = io.get_next_entry
#       @csv_file.write(entry.get_input_stream.read)
#         #entry.extract(@csv_file.path)
#     end
#   end
  
  def process_csv
    @csv_path = '/home/andy/temp/cyclestreets/planning applications/planning_applications.csv'
    count = 0
    csv = CSV.foreach(@csv_path, headers: true, header_converters: :symbol) do |row|
      record = PlanningApplication.find_by_openlylocal_id(row[:openlylocal_id])
      record = PlanningApplication.new unless record
      [:openlylocal_id, :openlylocal_url, :address, :postcode, :description, :council_name, :url, :uid].each do |symbol|
        record[symbol] = row[symbol]
      end
      record[:openlylocal_council_url] = row[:council_openlylocal_url]
      record.location = "POINT(#{row[:lng]} #{row[:lat]})"
      # Unhandled symbols:
      # updated_at retrieved_at decision status date_received date_validated start_date
      record.save!
      count += 1
      puts count
    end
  end

  def cleanup
    @tempfile.close if @tempfile
  end
end