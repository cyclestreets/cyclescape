# frozen_string_literal: true

class ThreadListDecorator < ApplicationDecorator
  alias_method :thread, :object

  def self.decl_auth_context
    :message_threads
  end

  def self.base_class
    MessageThread.base_class
  end

  MESSAGE_ICON_MAP = {
    'photo_message' => 'image',
    'link_message' => 'link',
    'deadline_message' => 'cal',
  }

  def latest_activity
    latest = thread.latest_message
    h.content_tag(:ul, class: 'content-icon-list') do
      h.content_tag(:li, class: MESSAGE_ICON_MAP.fetch(latest.component_name, 'library_note')) do
        creator_link = h.link_to_profile(latest.created_by)
        if latest.component_name == "thread_leader_message" && latest.component.withdrawing?
          h.t("dashboards.show.posted.thread_leader_withdrawing")
        else
          h.t("dashboards.show.posted.#{latest.component_name}_html", creator_link: creator_link)
        end
      end
    end
  end

  def latest_activity_date
    thread.latest_message.created_at
  end

  def title
    if h.permitted_to? :show, thread
      thread.display_title
    else
      I18n.t('decorators.thread_list.private_thread_title')
    end
  end

  def issue_title
    thread.issue.title
  end

  def issue_link
    h.link_to issue_title, thread.issue
  end

  def has_issue?
    thread.issue
  end

  def icon_class
    if has_issue?
      # Might be nil
      icon = thread.issue.icon_from_tags
    end
    icon || 'misc'
  end

  def following_status
    if h.current_user && h.current_user.subscribed_to_thread?(thread)
      h.content_tag(:div, class: 'following') do
        h.concat(h.image_tag('check-checked.png'))
        h.concat(I18n.t('decorators.thread_list.following'))
      end
    end
  end
end
