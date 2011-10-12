require 'spec_helper'

describe UserProfile do
  context "associations" do
    it { should belong_to(:user) }
  end
end
