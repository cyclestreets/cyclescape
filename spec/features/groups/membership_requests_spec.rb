require 'spec_helper'

describe 'Group Membership Requests' do
  let(:meg) { create(:meg) }

  context 'as a group member' do
    include_context 'signed in as a group member'
    let(:gmr) { create(:group_membership_request, group: current_group, user: meg) }

    describe 'viewing the requests' do
      it 'should refuse' do
        visit group_membership_requests_path(gmr.group)
        expect(page).to have_content('You are not authorised to access that page.')
      end
    end
  end

  context 'as a committee member' do
    include_context 'signed in as a committee member'
    let(:gmr) { create(:group_membership_request, group: current_group, user: meg) }

    describe 'confirming a request' do
      it 'should send a notification' do
        visit group_membership_requests_path(gmr.group)
        click_on 'Confirm'
        open_email(gmr.user.email)
        expect(current_email).to have_subject("You are now a member of the Cyclescape group for #{gmr.group.name}")
      end

      it 'should not html escape the name of the group' do
        current_group.name = 'A & B'
        current_group.save
        visit group_membership_requests_path(gmr.group)
        click_on 'Confirm'
        open_email(gmr.user.email)
        expect(current_email).to have_body_text('A & B')
      end

      it 'should let you view the user profile' do
        visit group_membership_requests_path(gmr.group)
        click_on gmr.user.name
        expect(page).to have_content(gmr.user.name)
        expect(current_path).to eql(user_profile_path(gmr.user))
      end

      it 'should let you review individual requests' do
        visit review_group_membership_request_path(gmr.group, gmr.id)
        click_on 'Confirm'
        open_email(gmr.user.email)
        expect(current_email).to have_subject("You are now a member of the Cyclescape group for #{gmr.group.name}")
      end

      it 'should show there was no message when reviewing' do
        visit review_group_membership_request_path(gmr.group, gmr.id)
        expect(page).to have_content(I18n.t('.group.membership_requests.review.no_message'))
      end

      context 'with a message' do
        let(:message) { 'My membership number is 012345' }
        let(:gmr) { create(:group_membership_request, group: current_group, user: meg, message: message) }

        it "should indicate there's a message when viewing the list" do
          visit group_membership_requests_path(gmr.group)
          expect(page).to have_link(I18n.t('.group.membership_requests.index.view_message'))
        end

        it 'should show the message when reviewing' do
          visit review_group_membership_request_path(gmr.group, gmr.id)
          expect(page).to have_content(I18n.t('.group.membership_requests.review.message'))
          expect(page).to have_content(message)
        end
      end
    end

    describe 'when being invited as a new member' do
      let(:credentials) { FactoryGirl.attributes_for(:user) }

      before do
        visit new_group_membership_path(group_id: current_group)
        fill_in 'Full name', with: credentials[:full_name]
        fill_in 'Email', with: credentials[:email]
        click_on 'Add member'
        click_on 'Sign out'
      end

      it 'should let you complete the invitation and change name and email' do
        mail = ActionMailer::Base.deliveries.last
        invitation_token = mail.body.raw_source.match(/invitation_token=(\w+)/)[1]
        visit accept_user_invitation_path(invitation_token: invitation_token)
        fill_in 'Full name', with: 'Shaun McDonald'
        fill_in 'Display name', with: 'smsm1'
        fill_in 'Email', with: 'some_other_email@example.com'
        fill_in 'New Password', with: 'Password1', match: :first
        fill_in 'New Password Confirmation', with: 'Password1'
        click_button 'Confirm account'
        expect(page).to have_content('Your password was set successfully. You are now signed in.')
        expect(User.find_by_email(credentials[:email])).to be_nil
        updated_user = User.find_by_email('some_other_email@example.com')
        expect(updated_user.full_name).to eq 'Shaun McDonald'
        expect(updated_user.display_name).to eq 'smsm1'
      end
    end
  end

  context 'as the original user' do
    include_context 'signed in as a site user'
    let(:group) { create(:group) }

    before do
      visit group_path(group)
      click_link I18n.t('.groups.join.join_this_group')
      click_button I18n.t('.formtastic.actions.group_membership_request.create')
    end

    describe 'cancelling the request' do
      it 'should cancel the request'
    end

    describe 'signing up again' do
      it 'should not show a link on the page' do
        visit group_path(group)
        expect(page).not_to have_content(I18n.t('.groups.join.join_this_group'))
        expect(page).to have_content(I18n.t('.groups.join.group_request_pending'))
      end

      it 'should not let you go directly' do
        visit new_group_membership_request_path(group)
        click_button I18n.t('.formtastic.actions.group_membership_request.create')
        expect(page).to have_content(I18n.t('.group.membership_requests.create.already_asked'))
      end
    end
  end

  context 'as a different user' do
    describe 'cancelling the request' do
      it 'should not cancel the request'
    end
  end

  context 'new request notifications' do
    include_context 'signed in as a site user'
    let(:group) { create(:group) }
    let(:message) { 'My membership number is 1234' }

    before do
      visit group_path(group)
      click_link I18n.t('.groups.join.join_this_group')
    end

    context 'with notifications turned off' do
      it 'should not send an email' do
        group.prefs.notify_membership_requests = false
        group.prefs.save!

        click_button I18n.t('.formtastic.actions.group_membership_request.create')
        expect(all_emails.count).to eql(0)
      end
    end

    context 'without a membership secretary' do
      it 'should send an email to the group' do
        click_button I18n.t('.formtastic.actions.group_membership_request.create')

        open_email(group.email)
        expect(current_email.subject).to include(current_user.name)
        expect(current_email.subject).to include(group.name)
        expect(current_email).to have_body_text('You can confirm or reject the membership request')

        expect(current_email).to have_body_text review_group_membership_request_url(group, group.pending_membership_requests.last)
        expect(current_email).to have_body_text group_membership_requests_url(group)
      end
    end

    context 'with a membership secretary' do
      let (:membership_secretary) { create(:user) }

      it 'should send an email to the membership secretary' do
        group.prefs.membership_secretary = membership_secretary
        group.prefs.save!
        click_button I18n.t('.formtastic.actions.group_membership_request.create')

        open_email(membership_secretary.email)
        expect(current_email.subject).to include(current_user.name)
        expect(current_email.subject).to include(group.name)
        expect(current_email).to have_body_text('You can confirm or reject the membership request')
      end
    end

    context 'member message' do
      it 'should include it in the email' do
        fill_in 'Message', with: message
        click_button I18n.t('.formtastic.actions.group_membership_request.create')

        open_email(group.email)
        expect(current_email).to have_body_text('They included a message with their request:')
        expect(current_email).to have_body_text(message)
      end

      it "should indicate if they didn't include a message" do
        click_button I18n.t('.formtastic.actions.group_membership_request.create')

        open_email(group.email)
        expect(current_email).to have_body_text('They did not include a message with their request')
      end
    end
  end
end
