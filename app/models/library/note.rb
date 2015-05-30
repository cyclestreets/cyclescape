# == Schema Information
#
# Table name: library_notes
#
#  id                  :integer          not null, primary key
#  library_item_id     :integer          not null
#  title               :string(255)
#  body                :text             not null
#  library_document_id :integer
#

class Library::Note < Library::Component
  include ActiveModel::ForbiddenAttributesProtection

  # Optional reference to a library document
  belongs_to :document, class_name: 'Library::Document', foreign_key: 'library_document_id'

  validates :body, presence: true

  # Set the decl_auth_context explicitly, since decl_auth has problems with
  # attribute checks on namespaced models. See
  # https://github.com/stffn/declarative_authorization/issues/120
  def self.decl_auth_context
    :library_notes
  end

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

  def searchable_text
    [body, read_attribute(:title)].join(' ')
  end

  # For authorization rules - doing range detection on TimeWithZones
  # iterates over every time in the range - integer ranges are optimized.
  def created_at_as_i
    created_at.to_i
  end
end
