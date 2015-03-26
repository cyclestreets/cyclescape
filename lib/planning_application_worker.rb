class PlanningApplicationWorker
  # Update to use
  # http://planit.org.uk/find/areas/json
  LOCAL_AUTHORITIES = [
    'Aberdeen', 'Aberdeenshire', 'Adur Worthing', 'Allerdale', 'Angus', 'Antrim', 'Ards', 'Armagh',
    'Arun', 'Babergh', 'Barnet', 'Barnsley', 'Basingstoke', 'Bath', 'Birmingham', 'Blackburn',
    'Boston', 'Breckland', 'Brecon Beacons', 'Brent', 'Brighton', 'Broadland', 'Broxbourne', 'Burnley',
    'Bury', 'Cairngorms', 'Cambridge', 'Cambridgeshire', 'Camden', 'Cannock Chase', 'Canterbury',
    'Carlisle', 'Carmarthenshire', 'Castle Point', 'Central Bedfordshire', 'Ceredigion', 'Charnwood',
    'Cheshire East', 'Christchurch', 'Colchester', 'Conwy', 'Cornwall', 'Coventry', 'Craven', 'Croydon',
    'Darlington', 'Dorset', 'Durham', 'Ealing', 'East Staffordshire', 'Epping Forest', 'Exmoor', 'Flintshire',
    'Guernsey Island', 'Hackney', 'Halton', 'Haringey', 'Hart', 'Hartlepool', 'Havering', 'High Peak',
    'Ipswich', 'Isle of Man', 'Isle of Wight', 'Islington', 'Lake District', 'Lichfield', 'Lincoln',
    'Lincolnshire', 'Liverpool', 'Loch Lomond', 'Luton', 'Malvern Hills', 'Mendip', 'Merthyr Tydfil',
    'Merton', 'Middlesbrough', 'North Warwickshire', 'North York Moors', 'Nuneaton', 'Orkney', 'Peak District',
    'Pembroke Coast', 'Pembrokeshire', 'Planning Inspectorate', 'Powys', 'Preston', 'Rhondda', 'Runnymede',
    'Rutland', 'Scilly Isles', 'Shetlands', 'Snowdonia', 'Somerset', 'South Downs', 'South Lanark', 'South Norfolk',
    'South Tyneside', 'Spelthorne', 'St Helens', 'Suffolk', 'Swansea', 'Tamworth', 'Tandridge', 'Taunton Deane',
    'Trafford', 'Walsall', 'Waltham Forest', 'Wandsworth', 'Warrington', 'Wellingborough', 'West Dorset',
    'West Suffolk', 'Weymouth', 'Wiltshire',
  ].freeze

  def initialize(end_date = (Date.today - 5.days))
    @end_date = end_date
  end

  def process!
    new_planning_applications = LOCAL_AUTHORITIES.map do |la|
      get_authorty(la)
    end.flatten
    add_applications new_planning_applications
  end

  private

  def conn
    @conn ||= Excon.new(Rails.application.config.planning_applications_url, headers: { 'Accept' => Mime::JSON.to_s, 'Content-Type' => Mime::JSON.to_s })
  end

  def get_authorty(authority)
    JSON.load(conn.request(generate_authority_requests(authority)).body)['records']
  end

  def add_applications(planning_applications)
    PlanningApplication.transaction do
      planning_applications.each do |remote_pa|
        next unless remote_pa['lng'] && remote_pa['uid'] && remote_pa['url']

        db_app = PlanningApplication.find_or_initialize_by_uid(remote_pa['uid'])
        [:address, :postcode, :description, :authority_name, :url, :start_date].each do |attr|
          db_app[attr] = remote_pa[attr.to_s]
        end
        db_app.location = "POINT(#{remote_pa['lng']} #{remote_pa['lat']})"
        db_app.save!
      end
    end
  end

  def generate_authority_requests(authority )
    {method: :get, idempotent: true, query:
     {auth: authority, start_date: (@end_date - 7.days).to_s, end_date: @end_date.to_s, pg_sz: 500, sort: '-start_date'}}
  end

end
