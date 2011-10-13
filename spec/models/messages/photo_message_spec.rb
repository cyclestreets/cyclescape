require "spec_helper"

describe PhotoMessage do
  describe "associations" do
    it { should belong_to(:message) }
    it { should belong_to(:thread) }
    it { should belong_to(:created_by) }
  end

  describe "validations" do
    it { should validate_presence_of(:photo) }
  end
end
