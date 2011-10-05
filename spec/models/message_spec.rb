# == Schema Information
#
# Table name: messages
#
#  id             :integer         not null, primary key
#  created_by_id  :integer         not null
#  thread_id      :integer         not null
#  body           :text            not null
#  component_id   :integer
#  component_type :string(255)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  deleted_at     :datetime
#

require 'spec_helper'

describe Message do
  describe "associations" do
    it { should belong_to(:created_by) }
    it { should belong_to(:thread) }
  end

  describe "validations" do
    it { should validate_presence_of(:created_by_id) }
    it { should validate_presence_of(:thread_id) }
    it { should validate_presence_of(:body) }
  end
end
