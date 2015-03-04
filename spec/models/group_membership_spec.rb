# == Schema Information
#
# Table name: group_memberships
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  group_id   :integer          not null
#  role       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#
# Indexes
#
#  index_group_memberships_on_group_id  (group_id)
#  index_group_memberships_on_user_id   (user_id)
#

require 'spec_helper'

describe GroupMembership do
  describe 'to be valid' do
    subject { GroupMembership.new }

    it 'must belong to a group' do
      expect(subject).to have(1).error_on(:group_id)
    end

    it "must belong to a user (except association build on new won't set it!)"

    it 'must have a role' do
      subject.role = ''
      expect(subject).to have(1).error_on(:role)
    end
  end

  describe 'role' do
    subject { GroupMembership.new }

    it 'should default to member' do
      expect(subject.role).to eql('member')
    end

    it "may be 'committee'" do
      subject.role = 'committee'
      expect(subject).to have(0).errors_on(:role)
    end

    it "may be 'member'" do
      subject.role = 'member'
      expect(subject).to have(0).errors_on(:role)
    end

    it 'may not be anything else' do
      subject.role = 'chipmunk'
      expect(subject).to have(1).error_on(:role)
    end
  end
end
