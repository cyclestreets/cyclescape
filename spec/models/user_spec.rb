require 'spec_helper'

describe User do
  describe 'newly created' do
    subject { create(:user) }

    it 'must have a member role' do
      expect(subject.role).to eq('member')
    end

    it 'should be active' do
      expect(subject.disabled).to be_falsey
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:memberships) }
    it { is_expected.to have_many(:groups) }
    it { is_expected.to have_many(:membership_requests) }
    it { is_expected.to have_many(:actioned_membership_requests) }
    it { is_expected.to have_many(:issues) }
    it { is_expected.to have_many(:created_threads) }
    it { is_expected.to have_many(:messages) }
    it { is_expected.to have_many(:locations) }
    it { is_expected.to have_many(:thread_subscriptions) }
    it { is_expected.to have_many(:subscribed_threads) }
    it { is_expected.to have_many(:thread_priorities) }
    it { is_expected.to have_many(:prioritised_threads) }
    it { is_expected.to have_one(:profile) }
    it { is_expected.to have_one(:prefs) }
    it { is_expected.to belong_to(:remembered_group) }
  end

  describe 'to be valid' do
    subject { build(:user) }

    it 'must have a role' do
      subject.role = ''
      expect(subject).not_to be_valid
    end

    it 'role can be a member' do
      subject.role = 'member'
      expect(subject).to be_valid
    end

    it 'role can be an admin' do
      subject.role = 'admin'
      expect(subject).to be_valid
    end

    it 'role cannot be an oompah loompa' do
      subject.role = 'oompah loompa'
      expect(subject).not_to be_valid
    end

    it 'must have a full name' do
      subject.full_name = ''
      expect(subject).to have(1).error_on(:full_name)
    end

    it 'must have a password' do
      subject.password = ''
      expect(subject).to have_at_least(1).error_on(:password)
    end

    it 'must have a password unless being invited' do
      subject.password = ''
      subject.valid? # trigger before_validation to set default role
      subject.invite!
      expect(subject).to have(0).errors_on(:password)
    end
  end

  describe 'with admin role' do
    it 'should have the admin role' do
      admin = build(:stewie)
      expect(admin.role).to eq('admin')
    end
  end

  describe 'name' do
    subject { build(:stewie) }
    let(:brian) { create(:brian) }

    it 'should use the full name if no display name is set' do
      subject.display_name = ''
      expect(subject.name).to eq('Stewie Griffin')
    end

    it 'should use the display name if set' do
      subject.display_name = 'Stewie'
      expect(subject.name).to eq('Stewie')
    end

    it 'should allow blank display names, but not duplicates' do
      expect(brian.display_name).to eq('Brian')
      subject.display_name = 'Brian'
      expect(subject).to have(1).errors_on(:display_name)

      brian.display_name = ''
      brian.save!
      subject.display_name = ''
      expect(subject).to have(0).errors_on(:display_name)
    end
  end

  context 'declarative authorization interface' do
    subject { build(:stewie) }

    it 'should respond to role_symbols' do
      expect(subject.role_symbols).to eq([:admin])
    end
  end

  describe 'profile association' do
    subject { build(:user) }

    it "should give a new blank profile if one doesn't already exist" do
      expect(subject.profile).to be_a(UserProfile)
      expect(subject.profile).to be_new_record
    end

    it 'should give the actual user profile if one exists' do
      profile = create(:user_profile, user: subject)
      expect(subject.profile).to eq(profile)
    end
  end

  describe 'preferences' do
    subject { create(:user) }

    it 'should be created with the user' do
      expect(subject.prefs).to be_a(UserPref)
    end
  end

  context 'name with email' do
    subject { build(:user) }

    it 'should give email in valid format using chosen name' do
      expect(subject.name_with_email).to eq("#{subject.name} <#{subject.email}>")
    end

    it 'should use full name if display name is not set' do
      subject.display_name = nil
      expect(subject.name_with_email).to eq("#{subject.full_name} <#{subject.email}>")
    end
  end

  context 'find_or_invite' do
    let(:attrs) { attributes_for(:user) }

    it 'should find an existing user from their email' do
      existing = User.create!(attrs)
      expect(User.find_or_invite(attrs[:email], attrs[:full_name])).to eq(existing)
    end

    it 'should invite a new user if their email is not found' do
      user = User.find_or_invite(attrs[:email], attrs[:full_name])
      expect(user).to be_invited_to_sign_up
    end

    it 'should set the full name of an existing user if their email is not found' do
      user = User.find_or_invite(attrs[:email], attrs[:full_name])
      expect(user.full_name).to eq(attrs[:full_name])
    end

    it 'should set the local-part as the full name if one is not provided' do
      user = User.find_or_invite(attrs[:email])
      expect(user.full_name).to eq(attrs[:email].split('@').first)
    end
  end

  context 'thread subscriptions' do
    subject { create(:user) }
    let(:thread) { create(:message_thread) }

    before do
      thread.subscribers << subject
    end

    it 'should have one thread subscription' do
      expect(subject.thread_subscriptions.size).to eq(1)
    end

    context 'subscribed_to_thread?' do
      it 'should return true if user is subscribed to the thread' do
        expect(subject.subscribed_to_thread?(thread)).to be_truthy
      end

      it 'should return false if user is not subscribed' do
        new_thread = create(:message_thread)
        expect(subject.subscribed_to_thread?(new_thread)).to be_falsey
      end
    end

    context 'subscribed threads' do
      it 'should have one thread' do
        expect(subject.subscribed_threads.size).to eq(1)
        expect(subject.subscribed_threads.first).to eq(thread)
      end

      it 'should not include thread when unsubscribed' do
        expect(subject.subscribed_threads).to include(thread)
        subscription = subject.thread_subscriptions.to(thread)
        subscription.destroy
        subject.reload
        expect(subject.subscribed_threads).not_to include(thread)
      end
    end
  end

  context 'involved threads' do
    subject { create(:user) }
    let(:thread) { create(:message_thread) }
    let(:message) { create(:message, created_by: subject, thread: thread) }

    it 'should be empty' do
      expect(subject.involved_threads).to be_empty
    end

    it 'should have a thread' do
      message
      expect(subject.involved_threads.size).to eq(1)
      expect(subject.involved_threads.first).to eq(message.thread)
    end
  end

  context 'prioritised threads' do
    subject { create(:user) }
    let(:thread) { create(:message_thread) }
    let!(:priority) { create(:user_thread_priority, user: subject, thread: thread) }

    it 'should contain the thread' do
      expect(subject.prioritised_threads).to include(thread)
    end
  end

  context 'thread views' do
    subject { create(:user) }
    let!(:thread_view) { create(:thread_view, user: subject) }

    it 'should indicate the user has viewed the thread' do
      expect(subject.viewed_thread?(thread_view.thread)).to be_truthy
    end

    it 'should give the time the user last viewed the thread' do
      expect(subject.viewed_thread_at(thread_view.thread).to_i).to eql(thread_view.viewed_at.to_i)
    end
  end

  it 'should have is_public scope' do
    private_user = create(:user)
    private_user.profile.update visibility: 'group'

    public_user = create(:user)
    public_user.profile.update visibility: 'public'

    public_users = described_class.is_public
    expect(public_users).to include(public_user)
    expect(public_users).to_not include(private_user)
  end

  context 'in a group' do
    subject { create(:user, full_name: 'Me') }
    let(:group) { create(:group) }
    let(:other_group) { create(:group) }

    before do
      create(:group_membership, user: subject, group: group)
    end

    it 'should be check if other users are viewable' do
      private_user_in_same_group = create(:user, full_name: 'private_user_in_same_group')
      create(:group_membership, user: private_user_in_same_group, group: group)
      private_user_in_same_group.profile.update visibility: 'group'

      private_user_in_different_group = create(:user, full_name: 'private_user_in_different_group')
      create(:group_membership, user: private_user_in_different_group, group: other_group)
      private_user_in_different_group.profile.update visibility: 'group'

      public_user = create(:user, full_name: 'public user')
      public_user.profile.update visibility: 'public'

      expect(subject.can_view(User.all)).to match_array([subject, private_user_in_same_group, public_user])
    end
  end

  context 'account disabling' do
    subject { create(:user) }

    it 'should be disabled' do
      subject.disabled = '1'
      expect(subject.disabled).to be_truthy
      expect(subject.disabled_at).to be_a_kind_of(Time)
    end

    it 'should be enabled' do
      subject.disabled = '1'
      subject.disabled = '0'
      expect(subject.disabled).to be_falsey
      expect(subject.disabled_at).to be_nil
    end

    it 'should work with mass-update' do
      subject.update(disabled: '1')
      subject.reload
      expect(subject.disabled).to be_truthy
    end
  end

  context 'account deleting' do
    subject { create(:user) }

    it 'should appear to be deleted' do
      subject
      expect(User.all).to include(subject)
      subject.destroy
      expect(User.all).not_to include(subject)
    end

    it 'should not really be deleted' do
      subject.destroy
      expect(User.with_deleted).to include(subject)
    end

    it 'should remove the display name and obfuscate the full name' do
      subject.destroy
      expect(subject.display_name).to be_nil
      expect(subject.name).to include('deleted')
      expect(subject.name).to include(subject.id.to_s)
    end

    it 'should clear the profile' do
      # Exact behaviour tested elsewhere
      expect(subject.profile).to receive(:clear).and_return(true)
      subject.destroy
    end

    context 'with locations' do
      subject { create(:user, :with_location) }

      it 'should remove the user location' do
        subject.destroy
        subject.reload
        expect(subject.locations).to be_empty
        expect(UserLocation.all.size).to eq(0)
      end
    end

    context 'subscribed to thread' do
      let!(:thread_subscription) { create(:thread_subscription, user: subject) }

      it 'should unsubscribe user from threads' do
        expect(subject.subscribed_threads.size).to eql(1)
        subject.destroy
        subject.reload
        expect(subject.subscribed_threads.size).to eql(0)
        expect(thread_subscription.thread.subscribers).not_to include(subject)
      end
    end

    context 'in a group' do
      let!(:group_membership) { create(:group_membership, user: subject) }

      it 'should remove member from the group' do
        expect(subject.groups.size).to eql(1)
        subject.destroy
        subject.reload
        expect(subject.groups.size).to eql(0)
        expect(group_membership.group.members).not_to include(subject)
      end
    end
  end

  context 'buffered locations' do
    subject { create(:user_with_location) }
    let(:point) { 'POINT(-1 1)' }
    let(:line) { 'LINESTRING (0 0, 0 1)' }
    let(:polygon) { 'POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))' }

    it 'should return polygon for point' do
      subject.locations[0].location = point
      expect(subject.buffered_locations.geometry_type.type_name).to eq('Polygon')
      expect(subject.buffered_locations).to eql(subject.locations[0].location.buffer(Geo::USER_LOCATIONS_BUFFER))
    end

    it 'should return polygon for line' do
      subject.locations[0].location = line
      expect(subject.buffered_locations.geometry_type.type_name).to eq('Polygon')
      expect(subject.buffered_locations).to eql(subject.locations[0].location.buffer(Geo::USER_LOCATIONS_BUFFER))
    end

    it 'should return polygon for polygon' do
      subject.locations[0].location = polygon
      expect(subject.buffered_locations.geometry_type.type_name).to eq('Polygon')
      expect(subject.buffered_locations).to eql(subject.locations[0].location.buffer(Geo::USER_LOCATIONS_BUFFER))
    end

    it 'should return multipolygon for point, line and polygon combined' do
      subject.locations[0].location = point
      subject.locations.create( location: line )
      subject.locations.create( location: polygon )
      expect(subject.buffered_locations.geometry_type.type_name).to eq('MultiPolygon')
    end
  end

  context 'issues near locations' do
    subject { create(:user_with_location) }
    let(:polygon) { 'POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))' }

    it 'should return correct issues' do
      a = 1 + Geo::USER_LOCATIONS_BUFFER / 2
      issue_in = create(:issue, location: 'POINT(0.5 0.5)')
      issue_close = create(:issue, location: "POINT(#{a} #{a})")
      issue_out = create(:issue, location: 'POINT(1.5 1.5)')
      subject.locations[0].location = polygon
      issues = subject.issues_near_locations
      expect(issues.count).to eql(2)
      expect(issues).to include(issue_in, issue_close)
      expect(issues).not_to include(issue_out)
    end
  end

  context 'start location' do
    subject { create(:user) }
    let(:group) { create(:group) }
    let(:group2) { create(:group) }
    let(:polygon) { 'POLYGON ((0 0, 0 1, 1 1, 1 0, 0 0))' }
    let(:user_location) { build(:user_location) }

    it 'should return a relevant location' do
      # start with nowhere
      expect(subject.start_location).to eql(Geo::NOWHERE_IN_PARTICULAR)

      # add a group with no location
      GroupMembership.create( user: subject, group: group, role: 'member' )
      subject.reload
      expect(subject.start_location).to eql(Geo::NOWHERE_IN_PARTICULAR)

      # add a group with a location
      group2.profile.location = polygon
      group2.profile.save!
      GroupMembership.create( user: subject, group: group2, role: 'member' )
      subject.reload
      expect(subject.start_location).to eql(group2.profile.location)

      # Then add a user location
      user_location.user = subject
      user_location.save!
      expect(subject.start_location).to eql(user_location.location)

      # Then test that the primary location category overrides it
      # todo
    end
  end

  context 'pending group membership requests' do
    subject { create(:user) }
    let(:group) { create(:group) }

    it 'should know if a group membership request is pending' do
      expect(subject.membership_request_pending_for?(group)).to be_falsey
      g = create(:group_membership_request, user: subject, group: group)
      subject.reload
      expect(subject.membership_request_pending_for?(group)).to be_truthy

      g.actioned_by = subject
      g.status = :confirmed
      g.save!
      subject.reload
      expect(subject.membership_request_pending_for?(group)).to be_falsey
    end
  end

  context 'confirmation' do
    it 'should not be confirmed' do
      user = create(:user, :unconfirmed)
      expect(user).not_to be_confirmed
    end
  end

  describe '#update_remembered_group' do
    let(:user) { create(:user) }
    let(:group) { create(:group) }

    it 'should update remembered_group_id given a group' do
      expect(user.remembered_group_id).to be_nil
      user.update_remembered_group(group)
      expect(user.remembered_group_id).to eq(group.id)
    end

    it 'should set the remembered_group_id to nil' do
      user.update_remembered_group(group)
      expect(user.remembered_group_id).to eq(group.id)
      user.update_remembered_group(nil)
      expect(user.remembered_group_id).to be_nil
    end
  end
end
