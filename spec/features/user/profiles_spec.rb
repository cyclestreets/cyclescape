require 'spec_helper'

describe 'User profiles' do
  let(:user) { FactoryGirl.create(:stewie_with_profile) }

  it "should display Stewie's profile" do
    visit user_profile_path(user)
    expect(current_path).to eq("/users/#{user.id}-#{user.name.parameterize}/profile")
    expect(page).to have_content(user.name)
  end

  context 'edit', as: :site_user do
    before do
      visit edit_user_profile_path(current_user)
    end

    it 'should upload a picture' do
      attach_file 'Picture', profile_photo_path
      click_on 'Save'
      expect(current_user.profile.picture).to be_truthy
    end

    it 'should set the website address' do
      fill_in 'Website', with: 'www.example.net'
      click_on 'Save'
      expect(current_user.profile.website).to eq('http://www.example.net')
    end

    it 'should set the biography' do
      fill_in 'About', with: lorem_ipsum
      click_on 'Save'
      expect(current_user.profile.about).to eq(lorem_ipsum.gsub(/\n/, "\r\n"))
    end
  end

  context 'permissions' do
    include_context 'signed in as a site user'

    it 'should let you edit your own profile' do
      visit edit_user_profile_path(current_user)
      expect(page).to have_content(I18n.t('.shared.profile_menu.edit'))
    end

    it 'should prevent you editing someone elses' do
      visit edit_user_profile_path(user)
      expect(page).to have_content('You are not authorised to access that page.')
    end
  end

  context 'adding to group' do
    include_context 'signed in as a committee member'
    let(:user) { FactoryGirl.create(:meg) }

    before do
      visit user_profile_path(user)
    end

    it 'should let you add the user to your group' do
      expect(page).to have_content("Add #{user.name} to your group")
      select 'Member', from: 'Membership type'
      click_on 'Add member'
      expect(page).to have_content("Members of #{current_group.name}")
      expect(page).to have_content(user.name)
    end
  end

  describe 'thread list', as: :site_user do
    let(:threads) { FactoryGirl.create_list(:message_thread, 3) }
    let(:first_messages) { FactoryGirl.create_list(:message, 3, thread: threads.first, created_by: current_user) }
    let(:second_messages) { FactoryGirl.create(:message, thread: threads.second, created_by: current_user) }

    it 'should show recent threads the user has posted to' do
      first_messages && second_messages
      visit user_profile_path(current_user)
      expect(page).to have_content(threads.first.title)
      expect(page).to have_content(threads.second.title)
    end

    it 'should not show private threads' do
      threads.first.update_column(:privacy, 'group')
      first_messages && second_messages
      visit user_profile_path(current_user)
      expect(page).to have_no_content(threads.first.title)
      expect(page).to have_content(threads.second.title)
    end
  end
end
