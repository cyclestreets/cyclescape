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
  pending "add some examples to (or delete) #{__FILE__}"
end
