# == Schema Information
#
# Table name: library_notes
#
#  id                  :integer         not null, primary key
#  library_item_id     :integer         not null
#  title               :string(255)
#  body                :text            not null
#  library_document_id :integer
#

class Library::Note < Library::Component
  # Optional reference to a library document
  belongs_to :document, class_name: "Library::Document", foreign_key: "library_document_id"

  validates :body, presence: true

  def self.new_on_document(doc)
    new document: doc
  end

  def title
    field = read_attribute(:title)
    if field.blank?
      body.truncate(30)
    else
      field
    end
  end

  def document?
    library_document_id?
  end
end
