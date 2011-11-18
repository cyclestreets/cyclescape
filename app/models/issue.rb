# == Schema Information
#
# Table name: issues
#
#  id            :integer         not null, primary key
#  created_by_id :integer         not null
#  title         :string(255)     not null
#  description   :text            not null
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  deleted_at    :datetime
#  category_id   :integer
#  location      :spatial({:srid=
#

class Issue < ActiveRecord::Base
  include Locatable
  include FakeDestroy

  acts_as_indexed :fields => [:title, :description]
  acts_as_voteable

  belongs_to :created_by, class_name: "User"
  belongs_to :category, class_name: "IssueCategory"
  has_many :threads, class_name: "MessageThread", after_add: :set_new_thread_defaults

  validates :title, presence: true
  validates :description, presence: true
  validates :location, presence: true

  validates :created_by, presence: true
  validates :category, presence: true

  default_scope where(deleted_at: nil)

  def to_param
    "#{id}-#{title.parameterize}"
  end

  protected

  # Association callback
  def set_new_thread_defaults(thread)
    thread.title ||= title
    thread.privacy ||= "public"
  end
end
