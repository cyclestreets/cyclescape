# == Schema Information
#
# Table name: location_categories
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe LocationCategory do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }

  describe 'associations' do
    it { is_expected.to have_many(:user_locations) }
  end
end
