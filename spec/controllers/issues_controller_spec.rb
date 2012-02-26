require 'spec_helper'

describe IssuesController do
  
  context "GET index" do
    before(:each) do
      @quahog_group_profile = FactoryGirl.create :quahogcc_group_profile
      @quahog_issue_1 = FactoryGirl.create :issue_within_quahog
      @quahog_issue_2 = FactoryGirl.create :issue_within_quahog
      @other_issue = FactoryGirl.create :issue_outside_quahog
    end
    
    it "should return all issues in the global context" do
      get :index
      assigns(:issues).count.should == 3
    end
  
    it "should only return issues within the group" do
      @request.host = "#{@quahog_group_profile.group.short_name}.example.com"
      get :index
      # FIXME Due to the has_one and belongs_to the group isn't able to pick up the group profile. How can we fix this?
      assigns(:group) == @quahog_group_profile.group
      assigns(:issues).count.should == 2
    end
    
    
    it "should return all issues matching a search phrase in the global context when doing a search" do
      pending
    end
    
    it "should return all issues matching a search phrase in the group context when doing a search within the group" do
      pending
    end
    
  
  end
  

end
