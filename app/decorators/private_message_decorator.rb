class PrivateMessageDecorator < ApplicationDecorator
  def created_at
    h.time_tag_with_title(source.created_at) do
      h.t('issues.show.issue_created_at', time_ago: h.time_ago_in_words(source.created_at))
    end
  end

  def other(current_user)
    current_user == source.created_by ? source.user : source.created_by
  end
end
