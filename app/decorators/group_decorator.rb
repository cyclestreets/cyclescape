class GroupDecorator < ApplicationDecorator
  decorates :group

  def description
    group.profile && group.profile.description
  end
end
