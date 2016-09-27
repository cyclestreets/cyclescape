require 'spec_helper'

describe CyclestreetsPhotoMessage, type: :model do
  it { is_expected.to validate_presence_of(:photo) }
  it { is_expected.to validate_presence_of(:location) }
end
