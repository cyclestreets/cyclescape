# == Schema Information
#
# Table name: library_documents
#
#  id              :integer          not null, primary key
#  library_item_id :integer          not null
#  title           :string(255)      not null
#  file_uid        :string(255)
#  file_name       :string(255)
#  file_size       :integer
#

class Library::Document < Library::Component
  include ActiveModel::ForbiddenAttributesProtection

  file_accessor :file do
    storage_path :generate_file_path
  end

  has_many :notes, foreign_key: 'library_document_id'

  validates :file, presence: true
  validates :title, presence: true

  def searchable_text
    # would be great to also use text content from within pdfs etc
    title
  end

  protected

  def generate_file_path
    hash = Digest::SHA1.file(file.path).hexdigest
    "library/documents/#{hash[0..2]}/#{hash[3..5]}/#{hash}"
  end
end
