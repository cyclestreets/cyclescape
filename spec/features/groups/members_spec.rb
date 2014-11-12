require 'spec_helper'

describe 'Group members' do
  context 'as a group member' do
    include_context 'signed in as a group member'

    before do
      visit group_members_path(current_group)
    end

    it 'should not let you view the page' do
      page.should have_content('You are not authorised to access that page.')
    end
  end

  context 'as a committee member' do
    include_context 'signed in as a committee member'

    context 'index' do
      before do
        @memberships = FactoryGirl.create_list(:group_membership, 4, group: current_group)
        visit group_members_path(current_group)
      end

      it 'should display the group name in the page title' do
        page.should have_title(current_group.name)
      end

      it 'should display the user name of the committee member' do
        within('.committee') do
          page.should have_content(current_user.name)
        end
      end

      it 'lists the member names' do
        @memberships.each do |member|
          page.should have_content(member.user.name)
        end
      end

      it 'should have a link to create a new member' do
        find_link('you can add them directly').should be_visible
      end

      it 'should let you review the membership request history' do
        page.should have_link(I18n.t('.group.members.index.review_requests'))
      end
    end

    context 'pending membership requests' do
      let!(:gmr) { FactoryGirl.create(:pending_gmr, group: current_group) }

      it 'should encourage you to review pending membership requests' do
        visit group_members_path(current_group)
        page.should have_link(I18n.t('.group.members.index.review_pending'))
      end
    end
  end
end
