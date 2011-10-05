# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  email                  :string(255)     default(""), not null
#  full_name              :string(255)     not null
#  display_name           :string(255)
#  role                   :string(255)     not null
#  encrypted_password     :string(128)     default("")
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  disabled_at            :datetime
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  invitation_token       :string(60)
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#

require 'spec_helper'

describe User do
  describe "newly created" do
    subject { FactoryGirl.create(:user) }

    it "must have a member role" do
      subject.role.should == "member"
    end
  end

  describe "to be valid" do
    subject { FactoryGirl.build(:user) }

    it "must have a role" do
      subject.role = ""
      subject.should_not be_valid
    end

    it "role can be a member" do
      subject.role = "member"
      subject.should be_valid
    end

    it "role can be an admin" do
      subject.role = "admin"
      subject.should be_valid
    end

    it "role cannot be an oompah loompa" do
      subject.role = "oompah loompa"
      subject.should_not be_valid
    end

    it "must have a full name" do
      subject.full_name = ""
      subject.should have(1).error_on(:full_name)
    end

    it "must have a password" do
      subject.password = ""
      subject.should have_at_least(1).error_on(:password)
    end

    it "must have a password unless being invited" do
      subject.password = ""
      subject.invite!
      subject.should have(0).errors_on(:password)
    end
  end

  describe "with admin role" do
    it "should have the admin role" do
      admin = FactoryGirl.build(:stewie)
      admin.role.should == "admin"
    end
  end

  describe "name" do
    subject { FactoryGirl.build(:stewie) }

    it "should use the full name if no display name is set" do
      subject.display_name = ""
      subject.name.should == "Stewie Griffin"
    end

    it "should use the display name if set" do
      subject.display_name = "Stewie"
      subject.name.should == "Stewie"
    end
  end

  context "declarative authorization interface" do
    subject { FactoryGirl.build(:stewie) }

    it "should respond to role_symbols" do
      subject.role_symbols.should == [:admin]
    end
  end
end
