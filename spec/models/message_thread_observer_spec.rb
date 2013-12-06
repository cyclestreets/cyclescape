require 'spec_helper'

describe MessageThreadObserver do
  subject { MessageThreadObserver.instance }

  context "basic checks" do
    let(:thread) { FactoryGirl.build(:message_thread) }

    it "should notice when MessageThreads are saved" do
      subject.should_receive(:after_save)

      MessageThread.observers.enable :message_thread_observer do
        thread.save
      end
    end
  end

  context "privacy" do
    let(:user) { FactoryGirl.create(:user) }
    let(:membership) { FactoryGirl.create(:group_membership, group: thread.group) }
    let(:member) { membership.user }
    let(:committee_membership) { FactoryGirl.create(:group_membership, group: thread.group, role: "committee") }
    let(:committee_member) { committee_membership.user }

    context "from public" do
      let(:thread) { FactoryGirl.create(:message_thread, :belongs_to_group) }

      context "to group" do
        it "should unsubscribe non-group members" do
          thread.add_subscriber(user)
          thread.subscribers.should include(user)
          MessageThread.observers.enable :message_thread_observer do
            thread.privacy = "group"
            thread.save
          end
          thread.reload
          thread.subscribers.should_not include(user)
        end

        it "should leave group members subscribed" do
          thread.add_subscriber(member)
          thread.subscribers.should include(member)
          MessageThread.observers.enable :message_thread_observer do
            thread.privacy = "group"
            thread.save
          end
          thread.reload
          thread.subscribers.should include(member)
        end
      end

      context "to committee" do
        it "should unsubscribe group members" do
          thread.add_subscriber(member)
          thread.subscribers.should include(member)
          MessageThread.observers.enable :message_thread_observer do
            thread.privacy = "committee"
            thread.save
          end
          thread.reload
          thread.subscribers.should_not include(member)
        end

        it "should leave committee members subscribed" do
          thread.add_subscriber(committee_member)
          thread.subscribers.should include(committee_member)
          MessageThread.observers.enable :message_thread_observer do
            thread.privacy = "committee"
            thread.save
          end
          thread.reload
          thread.subscribers.should include(committee_member)
        end
      end
    end

    context "from group private" do
      let(:thread) { FactoryGirl.create(:message_thread, :belongs_to_group, :private) }

      context "to public" do
        it "should try subscribe people who might have access" do
          ThreadSubscriber.should_receive(:subscribe_users).with(thread)
          MessageThread.observers.enable :message_thread_observer do
            thread.privacy = "public"
            thread.save
          end
        end
      end

      context "to committee" do
        it "should unsubscribe group members"
        it "should leave committee members subscribed"
      end
    end

    context "from committee" do
      let(:thread) { FactoryGirl.build(:message_thread, :belongs_to_group, :committee) }

      context "to group" do
        it "should subscribe group members"
      end

      context "to public" do
        it "should subscribe people with overlapping locations"
      end
    end
  end
end
