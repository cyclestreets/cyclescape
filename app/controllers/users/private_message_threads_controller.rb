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
    @private_threads = current_user.private_threads
  end

  private

  def load_user
    @user = User.find_by id: params[:user_id]
    permission_denied unless @user
  end
end
