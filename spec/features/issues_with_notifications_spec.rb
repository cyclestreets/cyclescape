require 'spec_helper'

describe 'Issue notifications' do
  include_context 'signed in as a site user'

  let(:issue_values) { attributes_for(:issue_with_json_loc, description: "hump & martini") }
  let(:thread_values) { attributes_for(:message_thread) }
  let(:location) { issue_values[:loc_json] }

  def fill_in_issue
    visit new_issue_path if page.current_path != new_issue_path
    fill_in I18n.t("formtastic.labels.issue.new.title"), with: issue_values[:title]
    fill_in I18n.t("formtastic.labels.issue.new.description"), with: issue_values[:description]
    fill_in I18n.t("formtastic.labels.issue.new.tags_string"), with: 'parking parking' # should cope with duplicates
    find('#issue_loc_json', visible: false).set(location)
    fill_in I18n.t("activerecord.attributes.message_thread.title"), with: thread_values[:title]
    fill_in "Message", with: "New message text"
  end

  context 'on a new issue' do
    it 'should create a new issue' do
      visit new_issue_path

      maxlength = find_field('Title')['maxlength']
      expect(maxlength).to eq("80")

      fill_in_issue
      click_on I18n.t("formtastic.actions.issue.create")

      within('#content header') do
        expect(page).to have_content(issue_values[:title])
      end
      expect(page).to have_content('parking')
      expect(page).to have_content(current_user.name)
    end

    describe 'for users with overlapping user locations' do
      let(:user) { create(:user) }
      let!(:user_location) { create(:user_location, user: user, loc_json: issue_values[:loc_json]) }
      let(:email) { open_last_email_for(user.email) }

      before do
        user.prefs.update!(involve_my_locations: location_email_prefs, email_status_id: email_status)
        fill_in_issue
        click_on I18n.t("formtastic.actions.issue.create")
      end

      context "when the user has emails" do
        let(:email_status) { 1 }

        context "when the user wants to be notified" do
          let(:location_email_prefs) { "notify" }

          it 'should send a notification' do
            expect(page).to have_content(issue_values[:title])
            expect(email).to have_subject("[Cyclescape] New issue - \"#{issue_values[:title]}\"")
            expect(email).to have_body_text(issue_values[:title])
            expect(email).to have_body_text(issue_values[:description])
            expect(email).not_to have_body_text('&amp;')
            expect(email).to have_body_text(current_user.name)
          end
        end

        context "when the user wants to be subscribed" do
          let(:location_email_prefs) { "subscribe" }

          it 'should send an email' do
            expect(email).not_to be_nil
          end
        end
      end

      context "when the user wants no emails" do
        let(:email_status) { 0 }
        let(:location_email_prefs) { "notify" }

        it "should not send an email when the emails aren't enabled" do
          expect(email).to be_nil
        end
      end
    end

    describe 'for users in groups with overlapping locations' do
      let!(:group_profile) { create(:quahogcc_group_profile) }
      let!(:notifiee) { create(:user) }
      let!(:group_membership) { create(:group_membership, user: notifiee, group: group_profile.group) }
      let(:email) { open_last_email_for(notifiee.email) }

      before do
        notifiee.prefs.update!(involve_my_groups: group_email_prefs, email_status_id: 1)
        fill_in_issue
        click_on I18n.t("formtastic.actions.issue.create")
      end

      context "when the user wants notifications" do
        let(:group_email_prefs) { "notify" }

        it 'should send a notification' do
          expect(email).to have_subject("[Cyclescape] New issue - \"#{issue_values[:title]}\" (#{group_profile.group.name})")
          email_body = email.text_part.decoded
          expect(email_body).to include("in the #{group_profile.group.name}'s area")
          expect(email_body).to include(issue_values[:description])
          expect(email_body).to include(issue_values[:title])
        end
      end

      context "when the user does not want notifications" do
        let(:group_email_prefs) { "none" }

        it "shouldn't send a notification" do
          expect(email).to be_nil
        end
      end
    end
  end

  context 'multiple overlapping locations' do
    let(:location_category) { create :location_category }
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let!(:user_location) { create(:user_location, user: user, location: 'POLYGON ((0.1 0.1, 0.1 0.2, 0.2 0.2, 0.2 0.1, 0.1 0.1))') }
    let(:location) { user_location.loc_json }

    before do
      user.prefs.update!(involve_my_locations: 'notify', email_status_id: 1)
      user2.prefs.update!(involve_my_locations: 'notify', email_status_id: 1)
      fill_in_issue
    end

    it 'should not send multiple emails to the same user' do
      email_count = all_emails.count
      click_on I18n.t("formtastic.actions.issue.create")
      expect(all_emails.count).to eq(email_count + 1)
    end

    context 'multiple users' do
      let!(:user2_location) do
        create(:user_location, user: user2, location: 'POLYGON ((0.1 0.1, 0.1 0.2, 0.2 0.2, 0.2 0.1, 0.1 0.1))')
      end

      it 'should send one email to multiple users' do
        email_count = all_emails.count
        click_on I18n.t("formtastic.actions.issue.create")
        expect(all_emails.count).to eq(email_count + 2)
      end
    end
  end

  context 'overlapping group and user locations' do
    let(:location_string) { 'POLYGON ((0.1 0.1, 0.1 0.2, 0.2 0.2, 0.2 0.1, 0.1 0.1))' }
    let(:location) { user_location.loc_json }
    let(:user) { create(:user) }
    let!(:user_location) { create(:user_location, user: user, location: location_string) }
    let!(:group_profile) { create(:group_profile, location: location_string) }
    let!(:group_membership) { create(:group_membership, user: user, group: group_profile.group) }

    before do
      user.prefs.update!(
        involve_my_locations: 'notify',
        involve_my_groups: 'notify',
        email_status_id: 1
      )
      fill_in_issue
    end

    # The user would normally receive two emails - one for the issue being within the group's area,
    # and a second email since the issue is also in one of their user locations.
    it 'should only send one email to the user' do
      email_count = all_emails.count
      click_on I18n.t("formtastic.actions.issue.create")
      expect(all_emails.count).to eq(email_count + 1)
    end
  end
end
