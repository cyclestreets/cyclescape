# frozen_string_literal: true

class MessageThread::UserFavouritesController < MessageThread::BaseController
  def create
    if favourite.save
      flash.now[:notice] = t(".success")
    else
      flash.now[:alert] = t(".failure")
    end
  end

  def destroy
    if favourite.destroy
      flash.now[:notice] = t(".success")
    else
      flash.now[:alert] = t(".failure")
    end
  end

  private

  def favourite
    @favourite ||= @thread.favourite_for(current_user)
    authorize @favourite
    @favourite
  end
end
