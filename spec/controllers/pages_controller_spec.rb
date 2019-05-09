# frozen_string_literal: true

require "spec_helper"

describe PagesController do
  it "should render the template given in the page param" do
    get :show, params: { page: "changelog" }
    expect(response).to render_template("changelog")
  end

  it "should return 404 if the page is not found" do
    expect { get :show, params: { page: "some-other" } }.to raise_error(ActionController::RoutingError)
  end
end
