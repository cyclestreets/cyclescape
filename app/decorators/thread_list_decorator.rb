class ThreadListDecorator < ApplicationDecorator
  def thread
    @model
  end

  def latest_activity
    latest = thread.latest_message
    h.content_tag(:ul, class: "content-icon-list") do
      h.content_tag(:li) do 
        creator_link = h.link_to_profile(latest.created_by)
        h.t("dashboards.show.posted.#{latest.component_name}_html", creator_link: creator_link)
      end
    end
  end

  def latest_activity_date
    "#{h.time_ago_in_words(thread.latest_message.created_at)} ago"
  end
end
