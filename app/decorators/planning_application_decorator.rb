class PlanningApplicationDecorator < ApplicationDecorator

  def planning_application
    @model
  end

  def issue_link
    h.link_to issue.title, planning_application.issue
  end

  def map
    h.render partial: "map", locals: {planning_application: planning_application}
  end

  def medium_icon_path(default=true)
    icon_path("m", default)
  end

  def icon_path(size, default=true)
    icon = nil
    icon ||= "planning" if default
    return "" if icon.nil?
    h.image_path "map-icons/#{size}-#{icon}.png"
  end
end