class Tag < ActiveRecord::Base
  validates :name, presence: true

  def self.names
    all.map {|tag| tag.name }
  end

  def self.grab(val)
    find_or_create_by_name(val)
  end

  def name=(val)
    if val.respond_to?(:downcase)
      write_attribute(:name, val.downcase)
    end
  end
end
