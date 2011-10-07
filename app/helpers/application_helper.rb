module ApplicationHelper
  def cancel_link(url = {action: :index})
    content_tag("li", class: "cancel") do
      link_to t("cancel"), url
    end
  end

  def user_groups(user = nil)
    user ||= current_user
    return [] if user.nil?
    user.groups
  end
end
