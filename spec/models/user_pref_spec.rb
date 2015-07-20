require 'spec_helper'

describe UserPref do
  it { is_expected.to belong_to(:user) }

  describe 'attributes' do
    booleans = %w(
      involve_my_groups_admin
      enable_email
      )

    booleans.each do |attr|
      it "should respond to #{attr} with true or false" do
        expect(subject.send(attr)).not_to be_nil
      end
    end

    strings = %w(
      involve_my_locations
      involve_my_groups
      )

    strings.each do |attr|
      it "should respond to #{attr} with a default value" do
        expect(subject.send(attr)).not_to be_nil
      end
    end
  end
end
