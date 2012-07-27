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
#  remembered_group_id    :integer
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string(255)
#

require 'spec_helper'

describe User do
  describe "newly created" do
    subject { FactoryGirl.create(:user) }

    it "must have a member role" do
      subject.role.should == "member"
    end

    it "should be active" do
      subject.disabled.should be_false
    end
  end

  describe "associations" do
    it { should have_many(:memberships) }
    it { should have_many(:groups) }
    it { should have_many(:membership_requests) }
    it { should have_many(:actioned_membership_requests) }
    it { should have_many(:issues) }
    it { should have_many(:created_threads) }
    it { should have_many(:messages) }
    it { should have_many(:locations) }
    it { should have_many(:thread_subscriptions) }
    it { should have_many(:subscribed_threads) }
    it { should have_many(:thread_priorities) }
    it { should have_many(:prioritised_threads) }
    it { should have_one(:profile) }
    it { should have_one(:prefs) }
    it { should belong_to(:remembered_group) }
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
      subject.valid? # trigger before_validation to set default role
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

  describe "profile association" do
    subject { FactoryGirl.build(:user) }

    it "should give a new blank profile if one doesn't already exist" do
      subject.profile.should be_a(UserProfile)
      subject.profile.should be_new_record
    end

    it "should give the actual user profile if one exists" do
      profile = FactoryGirl.create(:user_profile, user: subject)
      subject.profile.should == profile
    end
  end

  describe "preferences" do
    subject { FactoryGirl.create(:user) }

    it "should be created with the user" do
      subject.prefs.should be_a(UserPref)
    end
  end

  context "name with email" do
    subject { FactoryGirl.build(:user) }

    it "should give email in valid format using chosen name" do
      subject.name_with_email.should == "#{subject.name} <#{subject.email}>"
    end

    it "should use full name if display name is not set" do
      subject.display_name = nil
      subject.name_with_email.should == "#{subject.full_name} <#{subject.email}>"
    end
  end

  context "find_or_invite" do
    let(:attrs) { FactoryGirl.attributes_for(:user) }

    it "should find an existing user from their email" do
      existing = User.create!(attrs)
      User.find_or_invite(attrs[:email], attrs[:full_name]).should == existing
    end

    it "should invite a new user if their email is not found" do
      user = User.find_or_invite(attrs[:email], attrs[:full_name])
      user.should be_invited
    end

    it "should set the full name of an existing user if their email is not found" do
      user = User.find_or_invite(attrs[:email], attrs[:full_name])
      user.full_name.should == attrs[:full_name
    ]end

    it "should set the local-part as the full name if one is not provided" do
      user = User.find_or_invite(attrs[:email])
      user.full_name.should == attrs[:email].split("@").first
    end
  end

  context "thread subscriptions" do
    subject { FactoryGirl.create(:user) }
    let(:thread) { FactoryGirl.create(:message_thread) }

    before do
      thread.subscribers << subject
    end

    it "should have one thread subscription" do
      subject.should have(1).thread_subscription
    end

    context "subscribed_to_thread?" do
      it "should return true if user is subscribed to the thread" do
        subject.subscribed_to_thread?(thread).should be_true
      end

      it "should return false if user is not subscribed" do
        new_thread = FactoryGirl.create(:message_thread)
        subject.subscribed_to_thread?(new_thread).should be_false
      end
    end

    context "subscribed threads" do
      it "should have one thread" do
        subject.should have(1).subscribed_thread
        subject.subscribed_threads.first.should == thread
      end

      it "should not include thread when unsubscribed" do
        subject.subscribed_threads.should include(thread)
        subscription = subject.thread_subscriptions.to(thread)
        subscription.destroy
        subject.reload
        subject.subscribed_threads.should_not include(thread)
      end
    end
  end

  context "involved threads" do
    subject { FactoryGirl.create(:user) }
    let(:thread) { FactoryGirl.create(:message_thread) }
    let(:message) { FactoryGirl.create(:message, created_by: subject, thread: thread) }

    it "should be empty" do
      subject.involved_threads.should be_empty
    end

    it "should have a thread" do
      message
      subject.should have(1).involved_thread
      subject.involved_threads.first.should == message.thread
    end
  end

  context "prioritised threads" do
    subject { FactoryGirl.create(:user) }
    let(:thread) { FactoryGirl.create(:message_thread) }
    let!(:priority) { FactoryGirl.create(:user_thread_priority, user: subject, thread: thread) }

    it "should contain the thread" do
      subject.prioritised_threads.should include(thread)
    end
  end

  context "account disabling" do
    subject { FactoryGirl.create(:user) }

    it "should be disabled" do
      subject.disabled = "1"
      subject.disabled.should be_true
      subject.disabled_at.should be_a_kind_of(Time)
    end

    it "should be enabled" do
      subject.disabled = "1"
      subject.disabled = "0"
      subject.disabled.should be_false
      subject.disabled_at.should be_nil
    end

    it "should work with mass-update" do
      subject.update_attributes(disabled: "1")
      subject.reload
      subject.disabled.should be_true
    end
  end

  context "buffered locations" do
    subject { FactoryGirl.create(:user_with_location) }
    let(:point) { 'POINT(-1 1)' }
    let(:line) { 'LINESTRING (0 0, 0 1)' }
    let(:polygon) { 'POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))' }

    it "should return polygon for point" do
      subject.locations[0].location = point
      subject.buffered_locations.geometry_type.type_name.should eq("Polygon")
      subject.buffered_locations.should eql(subject.locations[0].location.buffer(Geo::USER_LOCATIONS_BUFFER))
    end

    it "should return polygon for line" do
      subject.locations[0].location = line
      subject.buffered_locations.geometry_type.type_name.should eq("Polygon")
      subject.buffered_locations.should eql(subject.locations[0].location.buffer(Geo::USER_LOCATIONS_BUFFER))
    end

    it "should return polygon for polygon" do
      subject.locations[0].location = polygon
      subject.buffered_locations.geometry_type.type_name.should eq("Polygon")
      subject.buffered_locations.should eql(subject.locations[0].location.buffer(Geo::USER_LOCATIONS_BUFFER))
    end

    it "should return multipolygon for point, line and polygon combined" do
      subject.locations[0].location = point
      subject.locations.create({location: line})
      subject.locations.create({location: polygon})
      subject.buffered_locations.geometry_type.type_name.should eq("MultiPolygon")
    end
  end

  context "issues near locations" do
    subject { FactoryGirl.create(:user_with_location) }
    let(:polygon) { 'POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))' }

    it "should return correct issues" do
      a = 1 + Geo::USER_LOCATIONS_BUFFER / 2
      issue_in = FactoryGirl.create(:issue, location: 'POINT(0.5 0.5)')
      issue_close = FactoryGirl.create(:issue, location: "POINT(#{a} #{a})")
      issue_out = FactoryGirl.create(:issue, location: 'POINT(1.5 1.5)')
      subject.locations[0].location = polygon
      issues = subject.issues_near_locations
      issues.count.should eql(2)
      issues.should include(issue_in, issue_close)
      issues.should_not include(issue_out)
    end
  end

  context "start location" do
    subject { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group) }
    let(:group2) { FactoryGirl.create(:group) }
    let(:polygon) { 'POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))' }
    let(:user_location) { FactoryGirl.build(:user_location) }

    it "should return a relevant location" do
      # start with nowhere
      subject.start_location.should eql(Geo::NOWHERE_IN_PARTICULAR)

      # add a group with no location
      GroupMembership.create(user: subject, group: group, role: "member")
      subject.reload
      subject.start_location.should eql(Geo::NOWHERE_IN_PARTICULAR)

      # add a group with a location
      group2.profile.location = polygon
      group2.profile.save!
      GroupMembership.create(user: subject, group: group2, role: "member")
      subject.reload
      subject.start_location.should eql(group2.profile.location)

      # Then add a user location
      user_location.user = subject
      user_location.save!
      subject.start_location.should eql(user_location.location)

      # Then test that the primary location category overrides it
      # todo
    end
  end

  context "pending group membership requests" do
    subject { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group) }

    it "should know if a group membership request is pending" do
      subject.membership_request_pending_for?(group).should be_false
      g = GroupMembershipRequest.create(user: subject, group: group)
      subject.reload
      subject.membership_request_pending_for?(group).should be_true

      g.actioned_by = subject
      g.status = :confirmed
      g.save!
      subject.reload
      subject.membership_request_pending_for?(group).should be_false
    end
  end

  context "confirmation" do
    it "should not be confirmed" do
      user = FactoryGirl.create(:user, :unconfirmed)
      user.should_not be_confirmed
    end
  end

  describe "#update_remembered_group" do
    let(:user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group) }

    it "should update remembered_group_id given a group" do
      user.remembered_group_id.should be_nil
      user.update_remembered_group(group)
      user.remembered_group_id.should == group.id
    end

    it "should set the remembered_group_id to nil" do
      user.update_remembered_group(group)
      user.remembered_group_id.should == group.id
      user.update_remembered_group(nil)
      user.remembered_group_id.should be_nil
    end
  end
end
