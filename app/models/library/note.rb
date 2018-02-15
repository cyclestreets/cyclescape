# frozen_string_literal: true

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

  # Optional reference to a library document
  belongs_to :document, class_name: 'Library::Document', foreign_key: 'library_document_id'

  validates :body, presence: true
  validates :url, url: true

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
      body.try(:truncate, 120)
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
end
