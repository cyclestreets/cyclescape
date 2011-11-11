class Library::Note < Library::Component
  # Optional reference to a library document
  belongs_to :document, class_name: "Library::Document", foreign_key: "library_document_id"

  validates :body, presence: true

  def title
    field = read_attribute(:title)
    if field.blank?
      body.truncate(30)
    else
      field
    end
  end
end
