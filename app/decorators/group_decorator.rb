class GroupDecorator < ApplicationDecorator
  decorates :group

  def description
    group.profile && group.profile.description
  end
  
  def trunctated_description
    group.profile && h.truncate(group.profile.description, length: 90, separator: ".", omission: "\u2026")
  end
  
  def loc_feature(properties = nil)
    group.profile && group.profile.loc_feature(properties)
  end
end
