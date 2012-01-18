require "spec_helper"

describe "User preferences" do
  include_context "signed in as a site user"

  def get_field(name)
    find_field(I18n.t("formtastic.labels.user_pref.#{name}"))
  end

  before do
    visit edit_user_prefs_path(current_user)
  end

  describe "send emails from subscribed threads" do
    let(:field) { get_field("notify_subscribed_threads") }

    it "should default to on" do
      field.should be_checked
    end

    it "should switch off" do
      field.set false  # Equivalent of uncheck
      click_on "Save"
      field.should_not be_checked
      # Get fresh copy of user
      User.find(current_user).prefs.notify_subscribed_threads.should be_false
    end
  end

  describe "notify of new issues in home locations" do
    let(:field) { get_field("notify_new_home_locations_issue") }

    it "should default to off" do
      field.should_not be_checked
    end

    it "should switch on" do
      field.set true
      click_on "Save"
      User.find(current_user).prefs.notify_new_home_locations_issue.should be_true
    end
  end

  describe "notification of new group threads" do
    let(:field) { get_field("notify_new_group_thread") }

    it "should default to on" do
      field.should be_checked
    end

    it "should switch off" do
      field.set false
      click_on "Save"
      User.find(current_user).prefs.notify_new_group_thread.should be_false
    end
  end

  describe "notification of new threads on group issues" do
    let(:field) { get_field("notify_new_issue_thread") }

    it "should default to off" do
      field.should_not be_checked
    end

    it "should switch on" do
      field.set true
      click_on "Save"
      User.find(current_user).prefs.notify_new_issue_thread.should be_true
    end
  end
end
