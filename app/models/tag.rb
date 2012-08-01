# == Schema Information
#
# Table name: tags
#
#  id   :integer         not null, primary key
#  name :string(255)     not null
#  icon :string(255)
#

class Tag < ActiveRecord::Base
  attr_accessible :name

  validates :name, presence: true

  def self.names
    scoped.map {|tag| tag.name }
  end

  def self.grab(val)
    find_or_create_by_name(normalise(val))
  end

  def name=(val)
    if val.is_a?(String)
      write_attribute(:name, self.class.normalise(val))
    end
  end

  def to_param
    name.parameterize
  end

  protected

  def self.normalise(tag)
    tag.strip.downcase
  end
end
