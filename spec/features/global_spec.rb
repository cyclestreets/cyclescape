require 'spec_helper'

describe 'Global settings' do
  context 'public' do
    before do
      visit root_path
    end

    it 'should set the authorization user to a guest' do
      expect(Authorization.current_user.role_symbols).to include(:guest)
    end

    it 'should show the current Git version in the footer' do
      within('footer') do
        expect(page).to have_content(Rails.application.config.git_hash)
      end
    end
  end

  context 'signed in', as: :site_user do
    it 'should set the authorization user to the signed in one' do
      expect(Authorization.current_user).to eq(current_user)
    end
  end
end
