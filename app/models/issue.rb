class Issue < ActiveRecord::Base
  belongs_to :created_by, class_name: "User"
  belongs_to :category, class_name: "IssueCategory"
  has_many :threads, class_name: "MessageThread"

  validates :title, presence: true
  validates :description, presence: true
  validates :location, presence: true

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

  def loc_json=(json_str)
    # Not clear why the factory is needed, should be taken care of by setting the srid on the factory_generator
    # but that doesn't work.
    factory = RGeo::Geos::Factory.new(srid: 4326)
    self.location = RGeo::GeoJSON.decode(json_str, :geo_factory => factory, :json_parser => :json).geometry
  end
end
