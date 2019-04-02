# frozen_string_literal: true

# Note inheritance
class Users::PrivateMessageThreadsController < MessageThreadsController
  before_filter :load_user, only: [:create, :new]
  filter_access_to :create, :new, attribute_check: true, model: User

  def new
    @thread = @user.private_threads.build
    @message = @thread.messages.build
  end

  def create
    @thread = @user.private_threads.build(
      permitted_params.merge(created_by: current_user, privacy: 'private')
    )
    super
  end

  def index
    threads = MessageThread.private_for(current_user).order_by_latest_message.to_a
    @private_threads = PrivateMessageDecorator.decorate_collection(threads)
    @unviewed_thread_ids = MessageThread.unviewed_thread_ids(user: current_user, threads: threads)
  end

  private

  def load_user
    @user = User.find_by id: params[:user_id]
    permission_denied unless @user
  end
end
