# frozen_string_literal: true

module ApplicationHelper
  def tweet_button(text:, link:, size: nil, via: 'cyclescape')
    link_to "Tweet", "https://twitter.com/intent/tweet",
      class: "twitter-share-button",
      data: { text: text, link: link, size: size, via: via}
  end

  def facebook_like(link, layout: 'button')
    tag(:div, class: "fb-share-button",
                data: { href: link, layout: layout} )
  end

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

  def email_message(message)
    mail_to "message-#{message.public_token}@#{domain}", t(".email"), encode: "hex"
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

  def vote_link(resource)
    case resource
    when Message
      {
        clear: vote_clear_thread_message_path(resource.thread, resource),
        up: vote_up_thread_message_path(resource.thread, resource),
        details: vote_detail_thread_message_path(resource.thread, resource)
      }
    when Issue
      {
        clear: vote_clear_issue_path(resource),
        up: vote_up_issue_path(resource),
        details: vote_detail_issue_path(resource)
      }
    end
  end

  def formatted_created_at(item)
    time_tag_with_title(item.created_at) do
      t('item_created_at', time_ago: time_ago_in_words(item.created_at))
    end
  end

  # used to turn references to threads into hyperlinks
  #
  # examples for threads:
  #  thread 1051
  #  thread no 1051
  #  thread no. 1051
  #  thread number 1051
  #  thread #1051
  # examples for issues:
  #  issue 1051
  #  issue no 1051
  #  issue no. 1051
  #  issue number 1051
  #  issue #1051
  def message_linkify(message)
    body = message.body.dup

    THREAD_FORMAT_MAP.each do |key, value|
      threads_found = body.scan(value)

      threads_found.each do |t|
        thread_id = t.match(/\d+/)[0]
        body.gsub!(t, "<a href=\"#{thread_path(thread_id.to_i)}\">#{t}</a>") if thread_id
      end
    end

    ISSUE_FORMAT_MAP.each do |key, value|
      issues_found = body.scan(value)

      issues_found.each do |i|
        issue_id = i.match(/\d+/)[0]
        # not a fan of making a database call here. Not sure how else to address parameterizing the issue url.
        issue = Issue.find_by(id: issue_id.to_i) if issue_id
        body.gsub!(i, "<a href=\"#{issue_path(issue)}\">#{i}</a>") if issue_id && issue
      end
    end

    if (group = message.thread.group)
      body = body.to_s.gsub(Hashtag::HASHTAG_REGEX) do
        link = link_to($LAST_MATCH_INFO[:hash_with_tag],
                       hashtag_link(group, $LAST_MATCH_INFO[:tag_name]), class: :hashtag)
        "#{$LAST_MATCH_INFO[:space]}#{link}"
      end
    end

    body
  end

  def hashtag_link(group, hashtag_name)
    "#{root_url(subdomain: group.short_name)}#{hashtag_path(hashtag_name)[1..-1]}"
  end

  def voter_names(voteable)
    voteable.votes.descending.includes(:voter).map do |v|
      v.voter.display_name_or_anon
    end.join("\r")
  end

  THREAD_FORMAT_MAP = {
    'thread :number' => /thread \d+/,
    'thread no :number' => /thread no \d+/,
    'thread no. :number' => /thread no. \d+/,
    'thread number :number' => /thread number \d+/,
    'thread #:number' => /thread #\d+/
  }.freeze

  ISSUE_FORMAT_MAP = {
    'issue :number' => /issue \d+/,
    'issue no :number' => /issue no \d+/,
    'issue no. :number' => /issue no. \d+/,
    'issue number :number' => /issue number \d+/,
    'issue #:number' => /issue #\d+/
  }.freeze
end
