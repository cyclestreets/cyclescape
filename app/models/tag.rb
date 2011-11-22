class Tag < ActiveRecord::Base
  validates :name, presence: true

  def name=(val)
    if val.respond_to?(:downcase)
      write_attribute(:name, val.downcase)
    end
  end
end
