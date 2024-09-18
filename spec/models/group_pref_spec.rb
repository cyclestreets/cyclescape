# frozen_string_literal: true


require "spec_helper"

describe GroupPref do
  describe "attributes" do
    booleans = %w[
      notify_membership_requests
    ]

    booleans.each do |attr|
      it "should respond to #{attr} with true or false" do
        expect(subject.send(attr)).not_to be_nil
      end
    end
  end
end
