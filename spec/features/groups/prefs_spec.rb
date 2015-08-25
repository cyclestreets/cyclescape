require 'spec_helper'

describe 'Group prefs' do

  def get_field(name)
    find_field(I18n.t("formtastic.labels.group_pref.#{name}"))
  end

  context 'as a group member' do
    include_context 'signed in as a group member'

    describe 'editing the group preferences' do
      it 'should refuse' do
        visit edit_group_prefs_path(current_group)
        expect(page).to have_content('You are not authorised to access that page.')
      end
    end
  end

  context 'as a group committee member' do
    include_context 'signed in as a committee member'

    describe 'editing the group preferences' do
      it 'should be permitted' do
        visit edit_group_prefs_path(current_group)
        expect(page).to have_content('Edit Preferences')
      end

      describe 'membership notifications' do
        let(:field) { get_field('notify_membership_requests') }

        before do
          visit edit_group_prefs_path(current_group)
        end

        it 'should default to on' do
          expect(field).to be_checked
        end

        it 'should let you turn them off' do
          field.set false
          click_on 'Save'
          expect(page).to have_content(I18n.t('.group.prefs.update.success'))
          current_group.reload
          expect(current_group.prefs.notify_membership_requests).to be_falsey
        end
      end

      it 'should let you pick a committee member as membership secretary' do
        membership = create(:group_membership, group: current_group, role: 'committee')
        visit edit_group_prefs_path(current_group)

        select membership.user.name, from: 'Membership secretary'
        click_on 'Save'
        current_group.reload
        expect(current_group.prefs.membership_secretary).to eql(membership.user)
      end

      it 'should let you deselect the membership secretary' do
        membership = create(:group_membership, group: current_group, role: 'committee')
        current_group.prefs.membership_secretary = membership.user
        current_group.prefs.save!

        visit edit_group_prefs_path(current_group)
        select '', from: 'Membership secretary'
        click_on 'Save'
        current_group.reload
        expect(current_group.prefs.membership_secretary).to be_nil
      end

      it 'should warn about blank emails' do
        current_group.email = ''
        current_group.save
        visit edit_group_prefs_path(current_group)

        expect(current_group.email).to be_blank
        expect(current_group.prefs.membership_secretary).to be_blank
        expect(current_group.prefs.notify_membership_requests).to be_truthy
        # ... therefore ...
        expect(page).to have_content(I18n.t('.group.prefs.edit.no_email_warning'))
      end
    end
  end

  context 'as a site admin' do
    include_context 'signed in as admin'

    describe 'editing any group preferences she wants to' do
      let(:group) { create(:quahogcc) }
      it 'should be permitted' do
        visit edit_group_prefs_path(group)
        expect(page).to have_content('Edit Preferences')
      end
    end
  end
end
