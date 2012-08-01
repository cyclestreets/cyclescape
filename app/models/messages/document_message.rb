# == Schema Information
#
# Table name: document_messages
#
#  id            :integer         not null, primary key
#  thread_id     :integer         not null
#  message_id    :integer         not null
#  created_by_id :integer         not null
#  title         :string(255)     not null
#  file_uid      :string(255)
#  file_name     :string(255)
#  file_size     :integer
#

class DocumentMessage < MessageComponent
  # Core associations defined in MessageComponent
  attr_accessible :title, :file, :retained_file

  file_accessor :file do
    storage_path :generate_file_path
  end

  validates :file, presence: true
  validates :title, presence: true

  protected

  def generate_file_path
    hash = Digest::SHA1.file(file.path).hexdigest
    "message_documents/#{hash[0..2]}/#{hash[3..5]}/#{hash}"
  end
end
