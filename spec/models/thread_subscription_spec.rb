require 'spec_helper'

describe ThreadSubscription do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:thread) }
  end
end
