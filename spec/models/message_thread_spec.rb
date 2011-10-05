# == Schema Information
#
# Table name: message_threads
#
#  id            :integer         not null, primary key
#  issue_id      :integer
#  created_by_id :integer         not null
#  group_id      :integer
#  title         :string(255)     not null
#  description   :text            not null
#  privacy       :string(255)     not null
#  state         :string(255)     not null
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

require 'spec_helper'

describe MessageThread do
  describe "associations" do
    it { should belong_to(:created_by) }
    it { should belong_to(:group) }
    it { should belong_to(:issue) }
    it { should have_many(:messages) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:created_by_id) }
    it { should allow_value("public").for(:privacy) }
    it { should allow_value("group").for(:privacy) }
    it { should_not allow_value("other").for(:privacy) }
  end
end
