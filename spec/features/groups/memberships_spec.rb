require 'spec_helper'

describe 'Group memberships admin' do
  let(:group) { create(:group) }

  context 'as an admin' do
    include_context 'signed in as admin'

    context 'new' do
      before do
        visit new_group_membership_path(group)
      end

      it 'should show the new member form' do
        expect(page).to have_field('Full name')
        expect(page).to have_field('Email')
      end
    end

    context 'create' do
      before do
        visit new_group_membership_path(group)
      end

      it 'should create a new group member and send an invitation email' do
        choose 'Member'
        fill_in 'Full name', with: 'Brian Griffin'
        fill_in 'Email', with: 'briang@example.com'
        click_button 'Add member'
        expect(User.find_by_email('briang@example.com')).to be_truthy
        email = open_email 'briang@example.com'
        expect(email.subject).to match(/Invitation/)
      end

      it 'should display an error if a name is not given' do
        choose 'Member'
        click_button 'Add member'
        expect(page).to have_content('Please enter a name')
      end

      context 'with existing user' do
        let(:new_member) { create(:user) }

        it 'should use an existing user if present' do
          choose 'Member'
          fill_in 'Email', with: new_member.email
          click_button 'Add member'
          expect(User.find_by_email(new_member.email).groups).to include(group)
        end
      end
    end
  end

  context 'as a group committee member' do
    include_context 'signed in as a committee member'

    before do
      visit new_group_membership_path(current_group)
    end

    context 'new' do
      it 'should show the page' do
        expect(page.status_code).to eq(200)
      end
    end

    context 'create' do
      context 'for unregistered users'
        it 'should create a new group member and send an invitation email' do
          choose 'Member'
          fill_in 'Full name', with: 'Meg Griffin'
          fill_in 'Email', with: 'meg@example.com'
          click_button 'Add member'
          expect(User.find_by_email('meg@example.com')).to be_truthy
          email = open_email 'meg@example.com'
          expect(email.subject).to match(/Invitation/)

          # Ensure they only get one invitation email and not e.g. added to group email
          expect(all_emails.count).to eql(1)
        end

      context 'for existing users' do
        let(:new_member) { create(:user) }

        it 'should send a confirmation email' do
          choose 'Member'
          fill_in 'Email', with: new_member.email
          click_button 'Add member'
          email = open_email new_member.email
          expect(email.subject).to match(/You are now a member/)

          expect(all_emails.count).to eql(1)
        end
      end
    end

    context 'edit' do
      let(:meg) { create(:meg) }

      it 'should let you promote a member into the committee' do
        create(:group_membership, group: current_group, user: meg)
        expect(current_group.committee_members).not_to include(meg)

        visit group_members_path(current_group)
        within('.members') do
          click_on 'Edit membership'
        end
        choose 'Committee'
        click_on 'Save'

        within('.committee') do
          expect(page).to have_content(meg.name)
        end
        expect(current_group.committee_members).to include(meg)
      end
    end
  end
end
