module ApplicationHelper
  include TweetButton

  TweetButton.default_tweet_button_options = { via: 'cyclescape', count: 'horizontal' }

  def cancel_link(url = { action: :index })
    content_tag('li', class: 'action link_action cancel') do
      link_to t('cancel'), url
    end
  end

  def user_groups(user = nil)
    user ||= current_user
    return [] if user.nil?
    user.groups
  end

  # Generate link to user or group profiles
  def link_to_profile(item, options = {})
    case item
      when User
        link_to item.name, user_profile_path(item), options
      when Group
        link_to item.name, group_path(item), options
    end
  end

  def link_to_group_home(group)
    link_to group.name, root_url(subdomain: group.short_name)
  end

  def link_to_github_commit
    commit = Rails.application.config.git_hash
    url = Rails.application.config.github_project_url + '/commit/' + commit
    link_to commit, url
  end

  def ajax_spinner_image
    image_tag 'spinner.gif'
  end

  def link_to_sign_in
    link_to t('sign_in'), new_user_session_path
  end

  # Taken from Rails 4, which allows passing a block for content.
  def time_tag(date_or_time, *args, &block)
    options  = args.extract_options!
    format   = options.delete(:format) || :long
    content  = args.first || I18n.l(date_or_time, :format => format)
    datetime = date_or_time.acts_like?(:time) ? date_or_time.xmlschema : date_or_time.iso8601

    content_tag(:time, content, options.reverse_merge(:datetime => datetime), &block)
  end

  def time_tag_with_title(date_or_time, &block)
    time_tag(date_or_time, title: l(date_or_time, format: :long), &block)
  end
end
