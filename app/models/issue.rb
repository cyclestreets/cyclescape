# == Schema Information
#
# Table name: issues
#
#  id            :integer          not null, primary key
#  created_by_id :integer          not null
#  title         :string(255)      not null
#  description   :text             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :datetime
#  location      :spatial          geometry, 4326
#  photo_uid     :string(255)
#
# Indexes
#
#  index_issues_on_created_by_id  (created_by_id)
#  index_issues_on_location       (location)
#

class Issue < ActiveRecord::Base
  include Locatable
  include FakeDestroy
  include Taggable

  attr_accessible :title, :description, :loc_json, :photo, :retained_photo, :tags_string

  acts_as_indexed fields: [:title, :description, :tags_string]
  acts_as_voteable
  image_accessor :photo do
    storage_path :generate_photo_path
  end

  belongs_to :created_by, class_name: 'User'
  has_many :threads, class_name: 'MessageThread', after_add: :set_new_thread_defaults
  has_and_belongs_to_many :tags, join_table: 'issue_tags'

  validates :title, presence: true
  validates :description, presence: true
  validates :location, presence: true
  validates :size, numericality: { less_than: Geo::ISSUE_MAX_AREA }

  validates :created_by, presence: true

  default_scope where(deleted_at: nil)
  scope :by_most_recent, order('created_at DESC')
  scope :created_by, ->(user) { where(created_by_id: user) }

  def to_param
    "#{id}-#{title.parameterize}"
  end

  # For authorization rules - doing range detection on TimeWithZones
  # iterates over every time in the range - integer ranges are optimized.
  def created_at_as_i
    created_at.to_i
  end

  protected

  # Association callback
  def set_new_thread_defaults(thread)
    thread.title ||= title if threads.count == 0
    thread.privacy ||= 'public'
  end

  def generate_photo_path
    hash = Digest::SHA1.file(photo.path).hexdigest
    "issue_photos/#{hash[0..2]}/#{hash[3..5]}/#{hash}"
  end
end
