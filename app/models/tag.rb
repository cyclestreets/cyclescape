class Tag < ActiveRecord::Base
  validates :name, presence: true

  def self.names
    scoped.map {|tag| tag.name }
  end

  def self.grab(val)
    find_or_create_by_name(val)
  end

  def name=(val)
    if val.is_a?(String)
      write_attribute(:name, val.strip.downcase)
    end
  end
end
