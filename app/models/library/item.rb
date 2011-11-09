class Library::Item < ActiveRecord::Base
  include FakeDestroy

  belongs_to :component, polymorphic: true
  belongs_to :created_by, class_name: "User"

  validates_presence_of :created_by, :component
end
