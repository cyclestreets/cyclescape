# frozen_string_literal: true

require "spec_helper"

describe LocationCategory do
  it { is_expected.to validate_presence_of(:name) }

  describe "associations" do
    it { is_expected.to have_many(:user_locations) }
  end
end
