# frozen_string_literal: true

module NewUi
  class BaseController < ApplicationController
    layout -> (controller) { controller.request.xhr? ? false : 'application' }
  end
end
