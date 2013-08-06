# encoding: UTF-8
require "spec_helper"

describe "Planning Applications" do
  context "show" do
    let(:planning_application) { FactoryGirl.create(:planning_application) }

    context "as a public user" do
      it "should not show you planning applications" do
        visit planning_application_path(planning_application)
        page.should have_content("You need to sign in or sign up before continuing.")
      end
    end

    context "as a signed in user" do
      include_context "signed in as a site user"

      before do
        visit planning_application_path(planning_application)
      end

      it "should show information about the planning application" do
        page.should have_content(planning_application.description)
        page.should have_content(planning_application.uid)
      end

      it "should have a link to convert to an issue" do
        page.should have_link(I18n.t(".planning_applications.show.convert_to_issue"))
      end
    end
  end

  context "convert to issue" do
    let(:planning_application) { FactoryGirl.create(:planning_application) }

    context "as a public user" do
      it "should not allow you" do
        visit new_planning_application_issue_path(planning_application)
        page.should have_content("You need to sign in or sign up before continuing.")
      end
    end

    context "as a signed in user" do
      include_context "signed in as a site user"

      it "should let you do the conversion" do
        visit planning_application_path(planning_application)
        click_on I18n.t(".planning_applications.show.convert_to_issue")
        current_path.should eql(new_planning_application_issue_path(planning_application))

        click_on I18n.t(".formtastic.actions.issue.create")
        issue = Issue.last
        issue.tags_string.should include("planning")
        issue.title.should eql(planning_application.title)
        issue.loc_json.should eql(planning_application.loc_json)
      end
    end
  end
end