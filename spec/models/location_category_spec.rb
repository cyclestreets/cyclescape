# == Schema Information
#
# Table name: location_categories
#
#  id         :integer         not null, primary key
#  name       :string(255)     not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe LocationCategory do
  it { should validate_presence_of(:name) }

  context "uniqueness" do
    before do
      FactoryGirl.create(:location_category)
    end

    it { should validate_uniqueness_of(:name) }
  end

  context "factory" do
    it "should be valid and save" do
      lc = FactoryGirl.build(:location_category)
      lc.should be_valid
      lc.save.should be_true
    end
  end

  describe "associations" do
    it { should have_many(:user_locations) }
  end
end
