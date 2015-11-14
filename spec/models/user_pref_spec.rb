require 'spec_helper'

describe UserPref do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_inclusion_of(:email_status_id).in_array(described_class.email_statuses.keys) }

  describe 'attributes' do
    booleans = %w(involve_my_groups_admin)

    booleans.each do |attr|
      it "should respond to #{attr} with true or false" do
        expect(subject.send(attr)).not_to be_nil
      end
    end

    strings = %w(involve_my_locations involve_my_groups)

    strings.each do |attr|
      it "should respond to #{attr} with a default value" do
        expect(subject.send(attr)).not_to be_nil
      end
    end
  end
end
