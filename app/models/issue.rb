class Issue < ActiveRecord::Base
  belongs_to :created_by, class_name: "User"
  belongs_to :category, class_name: "IssueCategory"
  has_many :threads, class_name: "MessageThread"

  validates :title, presence: true

  validates :created_by, presence: true
  validates :category, presence: true

  self.rgeo_factory_generator = RGeo::Geos.factory_generator

  # Define an approximate centre of the issue, for convenience.
  # Note that the line or polygon might be nowhere near this centre
  def centre
    case self.location.geometry_type
    when RGeo::Feature::Point
      return self.location
    else
      return self.location.envelope.centroid
    end
  end
end
