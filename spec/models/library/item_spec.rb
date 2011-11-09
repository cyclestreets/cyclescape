require 'spec_helper'

describe Library::Item do
  describe "associations" do
    it { should belong_to(:component) }
    it { should belong_to(:created_by) }
  end

  describe "validations" do
    it { should validate_presence_of(:created_by) }
    it { should validate_presence_of(:component) }
  end
end
