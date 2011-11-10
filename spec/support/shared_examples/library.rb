require "spec_helper"

shared_examples "a library component" do
  it { should belong_to(:item) }

  it "should respond to created_by" do
    subject.should respond_to(:created_by)
  end

  it "should respond to created_at" do
    subject.should respond_to(:created_at)
  end
end
