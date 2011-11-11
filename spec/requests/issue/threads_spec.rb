require "spec_helper"

describe "Issue threads" do
  let!(:issue) { FactoryGirl.create(:issue) }

  context "new" do
    context "as a site user" do
      include_context "signed in as a site user"

      it "should create a new public thread" do
        visit issue_path(issue)
        click_on "New Public Thread"
        fill_in "Message", with: "Awesome!"
        click_on "Create Thread"
        page.should have_content(issue.title)
        page.should have_content("Awesome!")
      end
    end

    context "as a group member" do
      include_context "signed in as a group member"

      it "should still create a new public thread" do
        visit issue_path(issue)
        click_on "New Public Thread"
        fill_in "Message", with: "Awesome!"
        click_on "Create Thread"
        page.should have_content(issue.title)
        page.should have_content("Awesome!")
        page.should have_content("Public: Everyone can view this thread and post messages.")
      end

      it "should create a new public group thread" do
        visit issue_path(issue)
        click_on "New #{current_group.name} Thread"
        fill_in "Message", with: "Awesome!"
        select "Public", from: "Privacy"
        click_on "Create Thread"
        page.should have_content(issue.title)
        page.should have_content("Awesome!")
        page.should have_content("Public: Everyone can view this thread and post messages.")
      end

      it "should create a new private group thread" do
        visit issue_path(issue)
        click_on "New #{current_group.name} Thread"
        fill_in "Message", with: "Awesome!"
        select "Group", from: "Privacy"
        click_on "Create Thread"
        page.should have_content(issue.title)
        page.should have_content("Awesome!")
        page.should have_content("Private: Only members of #{current_group.name} can view and post messages to this thread.")
      end

      it "should default to a public group thread" do
        visit issue_path(issue)
        click_on "New #{current_group.name} Thread"
        find_field('Privacy').find('option[selected]').text.should eql("Public")
      end

      context "in a secretive group" do
        before do
          current_group.default_thread_privacy = "group"
          current_group.save
        end

        it "should default to a private group thread" do
          visit issue_path(issue)
          click_on "New #{current_group.name} Thread"
          find_field('Privacy').find('option[selected]').text.should eql("Group")
        end
      end
    end
  end
end
