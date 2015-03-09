require 'rails_helper'

RSpec.describe "group_requests/edit", :type => :view do
  before(:each) do
    @group_request = assign(:group_request, GroupRequest.create!(
      :status => "MyString",
      :user_id => nil,
      :name => "",
      :subdomain => "MyString",
      :website => "MyString",
      :email => "MyString"
    ))
  end

  it "renders the edit group_request form" do
    render

    assert_select "form[action=?][method=?]", group_request_path(@group_request), "post" do

      assert_select "input#group_request_status[name=?]", "group_request[status]"

      assert_select "input#group_request_user_id[name=?]", "group_request[user_id]"

      assert_select "input#group_request_name[name=?]", "group_request[name]"

      assert_select "input#group_request_subdomain[name=?]", "group_request[subdomain]"

      assert_select "input#group_request_website[name=?]", "group_request[website]"

      assert_select "input#group_request_email[name=?]", "group_request[email]"
    end
  end
end
