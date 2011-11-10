class Library::Note < Library::Component
  # Optional reference to a library document
  belongs_to :document, class_name: "Library::Document", foreign_key: "library_document_id"

  validates :body, presence: true
end
