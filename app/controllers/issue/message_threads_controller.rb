# frozen_string_literal: true

class Issue::MessageThreadsController < MessageThreadsController
  def index
    skip_authorization
    redirect_to issue_path(issue)
  end

  def new
    @thread = issue.threads.build
    authorize @thread
    set_page_title issue.title
    if current_group
      @thread.group = current_group
      @thread.privacy = current_group.default_thread_privacy
    end
    @message = @thread.messages.build
    @message.body = issue.description if issue.threads.count == 0
  end

  def create
    @thread = issue.threads.build
    @thread.assign_attributes permitted_params.merge(created_by: current_user, tags: issue.tags)
    authorize @thread
    super
  end

  protected

  def issue
    @issue ||= Issue.find params[:issue_id]
  end
end
