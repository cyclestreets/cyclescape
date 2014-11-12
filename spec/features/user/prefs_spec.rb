require 'spec_helper'

describe 'User preferences' do
  include_context 'signed in as a site user'

  def get_field(name)
    find_field(I18n.t("formtastic.labels.user_pref.#{name}"))
  end

  before do
    visit edit_user_prefs_path(current_user)
  end

  describe 'involvement in user location matters' do
    it 'should default to subscribed' do
      within('#user_pref_involve_my_locations_input') do
        page.should have_checked_field(I18n.t('.user.prefs.edit.subscribe'))
      end
    end

    it 'should change to none' do
      within('#user_pref_involve_my_locations_input') do
        page.choose(I18n.t('.user.prefs.edit.none'))
      end
      click_on 'Save'
      within('#user_pref_involve_my_locations_input') do
        page.should have_checked_field(I18n.t('.user.prefs.edit.none'))
      end
      current_user.reload
      current_user.prefs.involve_my_locations.should eql('none')
    end
  end

  describe 'involvement in group matters' do
    it 'should default to notify' do
      within('#user_pref_involve_my_groups_input') do
        page.should have_checked_field(I18n.t('.user.prefs.edit.notify'))
        page.should_not have_checked_field(I18n.t('.user.prefs.edit.subscribe'))
        page.should_not have_checked_field(I18n.t('.user.prefs.edit.none'))
      end
    end

    it 'should change to subscribed' do
      within('#user_pref_involve_my_groups_input') do
        page.choose(I18n.t('.user.prefs.edit.subscribe'))
      end
      click_on 'Save'
      within('#user_pref_involve_my_groups_input') do
        page.should have_checked_field(I18n.t('.user.prefs.edit.subscribe'))
        page.should_not have_checked_field(I18n.t('.user.prefs.edit.notify'))
      end
      current_user.reload
      current_user.prefs.involve_my_groups.should eql('subscribe')
    end
  end

  describe 'involvement in group admin matters' do
    let(:field) { get_field('involve_my_groups_admin') }

    it 'should default to off' do
      field.should_not be_checked
    end

    it 'should switch on' do
      field.set true
      click_on 'Save'
      current_user.reload
      current_user.prefs.involve_my_groups_admin.should be_true
    end
  end

  describe 'enable email' do
    let(:field) { get_field('enable_email') }

    it 'should default to off' do
      field.should_not be_checked
    end

    it 'should switch on' do
      field.set true
      click_on 'Save'
      current_user.reload
      current_user.prefs.enable_email.should be_true
    end
  end

  describe 'profile visibility' do
    let(:field) { get_field('profile_visibility') }

    it 'should default to everyone' do
      within('#user_pref_profile_visibility_input') do
        page.should have_checked_field(I18n.t('.user.prefs.edit.profile_public'))
      end
    end

    it 'should change to group' do
      within('#user_pref_profile_visibility_input') do
        page.choose(I18n.t('.user.prefs.edit.profile_group'))
      end
      click_on 'Save'
      within('#user_pref_profile_visibility_input') do
        page.should have_checked_field(I18n.t('.user.prefs.edit.profile_group'))
      end
      current_user.reload
      current_user.prefs.profile_visibility.should eql('group')
    end
  end
end
