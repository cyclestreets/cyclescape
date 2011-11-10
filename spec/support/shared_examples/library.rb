require "spec_helper"

shared_examples "a library component" do
  it { should belong_to(:item) }
end
