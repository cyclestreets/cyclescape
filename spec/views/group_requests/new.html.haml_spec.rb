require 'rails_helper'

RSpec.describe "group_requests/new", :type => :view do
  before(:each) do
    assign(:group_request, GroupRequest.new(
      :status => "MyString",
      :user_id => nil,
      :name => "",
      :subdomain => "MyString",
      :website => "MyString",
      :email => "MyString"
    ))
  end

  it "renders new group_request form" do
    render

    assert_select "form[action=?][method=?]", group_requests_path, "post" do

      assert_select "input#group_request_status[name=?]", "group_request[status]"

      assert_select "input#group_request_user_id[name=?]", "group_request[user_id]"

      assert_select "input#group_request_name[name=?]", "group_request[name]"

      assert_select "input#group_request_subdomain[name=?]", "group_request[subdomain]"

      assert_select "input#group_request_website[name=?]", "group_request[website]"

      assert_select "input#group_request_email[name=?]", "group_request[email]"
    end
  end
end
