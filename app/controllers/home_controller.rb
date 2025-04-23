# frozen_string_literal: true

class HomeController < ApplicationController
  def show
    skip_authorization

    @tags = Tag.top_tags(10)
  end
end
