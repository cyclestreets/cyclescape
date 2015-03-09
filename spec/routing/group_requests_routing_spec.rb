require "rails_helper"

RSpec.describe GroupRequestsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/group_requests").to route_to("group_requests#index")
    end

    it "routes to #new" do
      expect(:get => "/group_requests/new").to route_to("group_requests#new")
    end

    it "routes to #show" do
      expect(:get => "/group_requests/1").to route_to("group_requests#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/group_requests/1/edit").to route_to("group_requests#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/group_requests").to route_to("group_requests#create")
    end

    it "routes to #update" do
      expect(:put => "/group_requests/1").to route_to("group_requests#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/group_requests/1").to route_to("group_requests#destroy", :id => "1")
    end

  end
end
