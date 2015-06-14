require 'spec_helper'

describe LocationCategory do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }

  describe 'associations' do
    it { is_expected.to have_many(:user_locations) }
  end
end
