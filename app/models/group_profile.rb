# == Schema Information
#
# Table name: group_profiles
#
#  id          :integer         not null, primary key
#  group_id    :integer         not null
#  description :text
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  location    :spatial({:srid=
#

class GroupProfile < ActiveRecord::Base
  include Locatable

  belongs_to :group
end
