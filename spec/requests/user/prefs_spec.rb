require "spec_helper"

describe "User preferences" do
  include_context "signed in as a site user"

  def get_field(name)
    find_field(I18n.t("formtastic.labels.user_pref.#{name}"))
  end

  before do
    visit edit_user_prefs_path(current_user)
  end

  describe "involvement in user location matters" do
    it "should default to subscribed" do
      within("#user_pref_involve_my_locations_input") do
        page.should have_checked_field("Subscribe")
      end
    end

    it "should change to none" do
      within("#user_pref_involve_my_locations_input") do
        page.choose("None")
      end
      click_on "Save"
      within("#user_pref_involve_my_locations_input") do
        page.should have_checked_field("None")
      end
      current_user.reload
      current_user.prefs.involve_my_locations.should eql("none")
    end
  end

  describe "involvement in group matters" do
    it "should default to notify" do
      within("#user_pref_involve_my_groups_input") do
        page.should have_checked_field("Notify")
        page.should_not have_checked_field("Subscribe")
        page.should_not have_checked_field("None")
      end
    end

    it "should change to subscribed" do
      within("#user_pref_involve_my_groups_input") do
        page.choose("Subscribe")
      end
      click_on "Save"
      within("#user_pref_involve_my_groups_input") do
        page.should have_checked_field("Subscribe")
        page.should_not have_checked_field("Notify")
      end
      current_user.reload
      current_user.prefs.involve_my_groups.should eql("subscribe")
    end
  end

  describe "involvement in group admin matters" do
    let(:field) { get_field("involve_my_groups_admin") }

    it "should default to off" do
      field.should_not be_checked
    end

    it "should switch on" do
      field.set true
      click_on "Save"
      current_user.reload
      current_user.prefs.involve_my_groups_admin.should be_true
    end
  end

  describe "enable email" do
    let(:field) { get_field("enable_email") }

    it "should default to off" do
      field.should_not be_checked
    end

    it "should switch on" do
      field.set true
      click_on "Save"
      current_user.reload
      current_user.prefs.enable_email.should be_true
    end
  end
end
