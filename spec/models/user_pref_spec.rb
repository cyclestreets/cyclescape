# == Schema Information
#
# Table name: user_prefs
#
#  id                      :integer          not null, primary key
#  user_id                 :integer          not null
#  involve_my_locations    :string(255)      default("subscribe"), not null
#  involve_my_groups       :string(255)      default("notify"), not null
#  involve_my_groups_admin :boolean          default(FALSE), not null
#  enable_email            :boolean          default(FALSE), not null
#
# Indexes
#
#  index_user_prefs_on_enable_email             (enable_email)
#  index_user_prefs_on_involve_my_groups        (involve_my_groups)
#  index_user_prefs_on_involve_my_groups_admin  (involve_my_groups_admin)
#  index_user_prefs_on_involve_my_locations     (involve_my_locations)
#  index_user_prefs_on_user_id                  (user_id) UNIQUE
#

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
