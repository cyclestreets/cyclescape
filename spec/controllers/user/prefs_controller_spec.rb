require 'spec_helper'

describe User::PrefsController, type: :controller do
  describe 'routing' do
    it { is_expected.to route(:get, '/profile/preferences').to(action: :edit) }
    it { is_expected.to route(:get, '/users/1/prefs/edit').to(action: :edit, user_id: 1) }
    it { is_expected.to route(:put, '/users/1/prefs').to(action: :update, user_id: '1') }
  end
end

