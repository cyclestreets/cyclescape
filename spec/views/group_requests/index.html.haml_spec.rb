require 'rails_helper'

RSpec.describe "group_requests/index", :type => :view do
  before(:each) do
    assign(:group_requests, [
      GroupRequest.create!(
        :status => "Status",
        :user_id => nil,
        :name => "",
        :subdomain => "Subdomain",
        :website => "Website",
        :email => "Email"
      ),
      GroupRequest.create!(
        :status => "Status",
        :user_id => nil,
        :name => "",
        :subdomain => "Subdomain",
        :website => "Website",
        :email => "Email"
      )
    ])
  end

  it "renders a list of group_requests" do
    render
    assert_select "tr>td", :text => "Status".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "Subdomain".to_s, :count => 2
    assert_select "tr>td", :text => "Website".to_s, :count => 2
    assert_select "tr>td", :text => "Email".to_s, :count => 2
  end
end
