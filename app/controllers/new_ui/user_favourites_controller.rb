# frozen_string_literal: true

module NewUi
  class UserFavouritesController < BaseController
    respond_to :json

    def create
      authorize favourite
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
      @favourite ||= thread.favourite_for(current_user)
    end

    def thread
      @thread ||= MessageThread.find(params[:id])
    end
  end
end
