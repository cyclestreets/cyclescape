require 'spec_helper'

describe UserLocationObserver do
  subject { UserLocationObserver.instance }

  context 'basic checks' do
    let(:ul) { FactoryGirl.build(:user_location) }

    it 'should notice when UserLocations are saved' do
      subject.should_receive(:after_save)

      UserLocation.observers.enable :user_location_observer do
        ul.save
      end
    end
  end

  context 'adding a location' do
    let(:issue) { FactoryGirl.create(:issue) }
    let!(:thread) { FactoryGirl.create(:issue_message_thread, issue: issue) }
    let(:user_location) { FactoryGirl.build(:user_location, location: issue.location) }
    let(:user) { user_location.user }
    let(:group) { FactoryGirl.create(:group) }

    context 'with pref' do
      before do
        user.prefs.update_column(:involve_my_locations, 'subscribe')
      end

      it 'should subscribe users to existing threads' do
        thread.subscribers.should_not include(user)
        UserLocation.observers.enable :user_location_observer do
          user_location.save
        end
        thread.reload
        thread.subscribers.should include(user)
      end

      it 'should not subscribe users to private threads' do
        group.members.should_not include(user)
        thread.group = group
        thread.privacy = 'group'
        thread.save
        UserLocation.observers.enable :user_location_observer do
          user_location.save
        end
        thread.reload
        thread.subscribers.should_not include(user)
      end
    end

    context 'without pref' do
      before do
        user.prefs.update_column(:involve_my_locations, 'notify')
      end

      it 'should not subscribe users to existing threads' do
        thread.subscribers.should_not include(user)
        UserLocation.observers.enable :user_location_observer do
          user_location.save
        end
        thread.reload
        thread.subscribers.should_not include(user)
      end
    end
  end
end
