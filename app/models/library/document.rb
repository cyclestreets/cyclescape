# frozen_string_literal: true


class Library::Document < Library::Component
  dragonfly_accessor :file do
    storage_options :generate_file_path
  end

  has_many :notes, foreign_key: "library_document_id"

  validates :file, presence: true
  validates :title, presence: true

  def searchable_text
    # would be great to also use text content from within pdfs etc
    title
  end

  protected

  def generate_file_path
    hash = Digest::SHA1.file(file.path).hexdigest
    { path: "library/documents/#{hash[0..2]}/#{hash[3..5]}/#{hash}" }
  end
end

# == Schema Information
#
# Table name: library_documents
#
#  id              :integer          not null, primary key
#  file_name       :string(255)
#  file_size       :integer
#  file_uid        :string(255)
#  title           :string(255)      not null
#  created_at      :datetime
#  updated_at      :datetime
#  library_item_id :integer          not null
#
# Indexes
#
#  index_library_documents_on_library_item_id  (library_item_id)
#
