require "spec_helper"

describe "Issue threads" do
  let!(:issue) { FactoryGirl.create(:issue) }

  context "new" do
    context "as a site user" do
      include_context "signed in as a site user"

      it "should create a new public thread" do
        visit issue_path(issue)
        click_on "New Thread"
        fill_in "Message", with: "Awesome!"
        click_on "Create Thread"
        page.should have_content(issue.title)
        page.should have_content("Awesome!")
        current_user.subscribed_to_thread?(issue.threads.last).should be_true
      end
    end

    context "as a group member" do
      include_context "signed in as a group member"

      it "should still create a new public thread" do
        visit issue_path(issue)
        click_on "New Thread"
        fill_in "Message", with: "Awesome!"
        click_on "Create Thread"
        page.should have_content(issue.title)
        page.should have_content("Awesome!")
        page.should have_content("Public: Everyone can view this thread and post messages.")
      end

      it "should create a new public group thread" do
        visit issue_path(issue)
        click_on "New Thread"
        select current_group.name, from: "Owned by"
        fill_in "Message", with: "Awesome!"
        select "Public", from: "Privacy"
        click_on "Create Thread"
        page.should have_content(issue.title)
        page.should have_content("Awesome!")
        page.should have_content("Public: Everyone can view this thread and post messages.")
      end

      it "should create a new private group thread" do
        visit issue_path(issue)
        click_on "New Thread"
        select current_group.name, from: "Owned by"
        fill_in "Message", with: "Awesome!"
        select "Group", from: "Privacy"
        click_on "Create Thread"
        page.should have_content(issue.title)
        page.should have_content("Awesome!")
        page.should have_content("Private: Only members of #{current_group.name} can view and post messages to this thread.")
      end
    end
  end
end
