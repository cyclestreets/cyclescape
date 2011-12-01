require "spec_helper"

describe "Global settings" do
  context "public" do
    before do
      visit root_path
    end

    it "should set the mailer default URL to the current host" do
      ActionMailer::Base.default_url_options[:host].should == "www.example.com"
    end

    it "should set the authorization user to a guest" do
      Authorization.current_user.role_symbols.should include(:guest)
    end

    it "should show the current Git version in the footer" do
      within("footer") do
        page.should have_content(Rails.application.config.git_hash)
      end
    end
  end

  context "signed in", as: :site_user do
    it "should set the authorization user to the signed in one" do
      Authorization.current_user.should == current_user
    end
  end
end
