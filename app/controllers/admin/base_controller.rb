module Admin
  class BaseController < ApplicationController
    before_action :verify_admin

    def verify_admin
      authorize :admin, :all?
    end
  end
end
