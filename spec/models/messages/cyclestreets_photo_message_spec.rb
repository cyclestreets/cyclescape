# frozen_string_literal: true

require "spec_helper"

describe CyclestreetsPhotoMessage, type: :model do
  it { is_expected.to validate_presence_of(:photo) }
  it { is_expected.to validate_presence_of(:location) }

  it "should have searchable_text" do
    expect { subject.searchable_text }.to_not raise_error
  end
end
