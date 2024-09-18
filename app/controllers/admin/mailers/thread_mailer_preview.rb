# frozen_string_literal: true

class ThreadMailerMailerPreview < ActionMailer::Preview
  before_action :verify_admin

  def digest_message
    messages = Message.order(updated_at: :desc).limit(30).includes(:thread).to_a
    ThreadMailer.digest(User.last, messages.group_by(&:thread))
  end

  def new_action_message
    ThreadMailer.common(*message(ActionMessage))
  end

  def new_cyclestreets_photo_message
    ThreadMailer.common(*message(CyclestreetsPhotoMessage))
  end

  def new_deadline_message
    ThreadMailer.common(*message(DeadlineMessage))
  end

  def new_document_message
    ThreadMailer.common(*message(DocumentMessage))
  end

  def new_library_item_message
    ThreadMailer.common(*message(LibraryItemMessage))
  end

  def new_link_message
    ThreadMailer.common(*message(LinkMessage))
  end

  def new_map_message
    ThreadMailer.common(*message(MapMessage))
  end

  def new_photo_message
    ThreadMailer.common(*message(PhotoMessage))
  end

  def new_street_view_message
    ThreadMailer.common(*message(StreetViewMessage))
  end

  def new_thread_leader_message
    ThreadMailer.common(*message(ThreadLeaderMessage))
  end

  def new_poll_message
    ThreadMailer.common(*message(PollMessage))
  end

  private

  def message(klass)
    mes = klass.last
    [mes.message, mes.thread.subscribers.sample]
  end

  def verify_admin
    authorize :admin, :all?
  end
end
