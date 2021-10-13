# frozen_string_literal: true

class MessageThread::UserFavouritesController < MessageThread::BaseController
  respond_to :json

  def create
    if favourite.save
      flash[:notice] = t(".success")
    else
      flash[:alert] = t(".failure")
    end
  end

  def destroy
    if favourite.destroy
      flash[:notice] = t(".success")
    else
      flash[:alert] = t(".failure")
    end
  end

  private

  def favourite
    @favourite ||= @thread.favourite_for(current_user)
  end
end
