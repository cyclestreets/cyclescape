# frozen_string_literal: true

require "spec_helper"

describe StreetViewMessage, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:caption) }
    it { is_expected.to validate_presence_of(:heading) }
    it { is_expected.to validate_presence_of(:pitch) }
    it { is_expected.to validate_presence_of(:location) }
  end

  it "sets location from a string" do
    subject.update(location_string: "(53.456, -1.123)")
    expect(subject.location.x).to eq(-1.123)
    expect(subject.location.y).to eq(53.456)
  end
end
