# frozen_string_literal: true

require "spec_helper"

shared_examples "a library component" do
  it "should respond to created_by" do
    expect(subject).to respond_to(:created_by)
  end

  it "should respond to created_at" do
    expect(subject).to respond_to(:created_at)
  end
end
