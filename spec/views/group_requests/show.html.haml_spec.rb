require 'rails_helper'

RSpec.describe "group_requests/show", :type => :view do
  before(:each) do
    @group_request = assign(:group_request, GroupRequest.create!(
      :status => "Status",
      :user_id => nil,
      :name => "",
      :subdomain => "Subdomain",
      :website => "Website",
      :email => "Email"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Status/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Subdomain/)
    expect(rendered).to match(/Website/)
    expect(rendered).to match(/Email/)
  end
end
