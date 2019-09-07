# frozen_string_literal: true


class Library::Note < Library::Component
  # Optional reference to a library document
  belongs_to :document, class_name: "Library::Document", foreign_key: "library_document_id"

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
    field = self[:title]
    field.presence || body.try(:truncate, 120)
  end

  def document?
    library_document_id?
  end

  def searchable_text
    [body, self[:title]].join(" ")
  end
end

# == Schema Information
#
# Table name: library_notes
#
#  id                  :integer          not null, primary key
#  body                :text             not null
#  title               :string(255)
#  url                 :string
#  created_at          :datetime
#  updated_at          :datetime
#  library_document_id :integer
#  library_item_id     :integer          not null
#
# Indexes
#
#  index_library_notes_on_library_document_id  (library_document_id)
#  index_library_notes_on_library_item_id      (library_item_id)
#
