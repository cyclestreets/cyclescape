require 'spec_helper'

describe ThreadSubscription do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:thread) }
  end
end
