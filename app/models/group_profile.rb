class GroupProfile < ActiveRecord::Base
  include Locatable

  belongs_to :group
end
