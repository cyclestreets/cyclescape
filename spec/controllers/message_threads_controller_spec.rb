# frozen_string_literal: true

require "spec_helper"

describe MessageThreadsController do
  let(:thread) { create(:message_thread) }

  describe "thread views" do
    let!(:message_a) { create(:message, thread: thread, created_at: Time.now.in_time_zone - 4.days) }
    let!(:message_b) { create(:message, thread: thread, created_at: Time.now.in_time_zone - 3.days) }
    let!(:message_c) { create(:message, thread: thread, created_at: Time.now.in_time_zone - 2.days) }

    context "as a guest" do
      it "should not assign a message to view from" do
        get :show, params: { id: thread.id }
        expect(assigns(:view_from)).to be_nil
      end
    end

    context "as a site user" do
      let(:user) { create(:user) }

      before do
        warden.set_user user
      end

      context "who hasn't viewed the thread before" do
        it "should not assign a message to view from" do
          get :show, params: { id: thread.id }
          expect(assigns(:view_from)).to be_nil
        end
      end

      context "who viewed the thread and no messages have been posted since" do
        it "should assign the final message" do
          create(:thread_view, thread: thread, user: user, viewed_at: Time.now.in_time_zone - 1.day)
          thread.reload
          get :show, params: { id: thread.id }
          expect(assigns(:view_from)).to eql(thread.messages.last)
        end
      end

      context "who viewed the thread and two messages have been posted since" do
        it "should assign the first of the new messages" do
          create(:thread_view, thread: thread, user: user, viewed_at: Time.now.in_time_zone - 3.5.days)
          get :show, params: { id: thread.id }
          expect(assigns(:view_from)).to eql(message_b)
        end
      end
    end
  end

  describe "closing / opening" do
    before do
      warden.set_user user_type
    end

    let(:subscription)   { create :thread_subscription, thread: thread }
    let(:subscriber)     { subscription.user }
    let(:non_subscriber) { create :user }

    describe "closing" do
      subject { put :close, params: { id: thread.id } }

      context "as a subscriber" do
        let(:user_type) { subscriber }

        it "can close the thread" do
          expect(subject.status).to eq 302
          expect(subject).to redirect_to "/threads/#{thread.id}"
        end
      end

      context "as a non subscriber" do
        let(:user_type) { non_subscriber }

        it { expect(subject.status).to eq 401 }
      end
    end

    describe "opening" do
      before { thread.update_column(:closed, true) }

      subject { put :open, params: { id: thread.id } }

      context "as a subscriber" do
        let(:user_type) { subscriber }

        it "can open the thread" do
          expect(subject.status).to eq 302
          expect(subject).to redirect_to "/threads/#{thread.id}"
        end
      end

      context "as a non subscriber" do
        let(:user_type) { non_subscriber }

        it { expect(subject.status).to eq 401 }
      end
    end
  end

  describe "#update changing the thread's group and privacy" do
    let(:user) { create(:user) }
    let(:not_in_group) { create :group, default_thread_privacy: "group" }
    let(:committee_group) { create :group, default_thread_privacy: "group" }
    let(:member_group) { create :group, default_thread_privacy: "group" }
    let(:thread) { create(:message_thread_with_messages, group: committee_group, created_by: creator) }
    let(:creator) { create(:group_membership, :committee, group: committee_group).user }

    before do
      warden.set_user user
      create(:group_membership, group: member_group, user: user)
      create(:group_membership, :committee, group: committee_group, user: user)
    end

    subject { put :update, params: { id: thread.id, thread: {group_id: group.id, privacy: privacy} } }

    context "when the user is not in the group" do
      let(:group) { not_in_group }
      let(:privacy) { "group" }

      it "does not allow the change" do
        expect(subject.status).to eq 200
        expect(flash[:notice]).to_not be_present
      end
    end

    context "when the user is a normal member of the group" do
      let(:group) { member_group }

      context "when changing the privacy to public" do
        let(:privacy) { "public" }

        it "does not allow the change" do
          expect(subject.status).to eq 200
          expect(flash[:notice]).to_not be_present
        end
      end

      context "when changing the privacy to group" do
        let(:privacy) { "group" }

        it "does allow the change" do
          expect(subject.status).to eq 302
          expect(flash[:notice]).to be_present
        end
      end
    end

    context "when the user is a committee member of the group" do
      let(:group) { committee_group }

      context "when changing the privacy to public" do
        let(:privacy) { "public" }

        it "does allow the change" do
          expect(subject.status).to eq 302
          expect(flash[:notice]).to be_present
        end
      end
    end
  end

  describe "updating the title" do
    let(:user) { thread.created_by }

    before do
      warden.set_user user
    end

    context "within 24h of the thread being created" do
      it "allows only the title to be updated" do
        put :update, params: { id: thread.id, thread: { title: "A new title", privacy: MessageThread::GROUP } }
        expect(response.status).to eq 302
        expect(thread.reload.title).to eq("A new title")
        expect(thread.privacy).to eq MessageThread::PUBLIC
      end
    end

    context "outside of 24h of the thread being created" do
      before do
        thread.update!(created_at: 25.hours.ago)
      end

      it "changes are not permitted" do
        put :update, params: { id: thread.id, thread: { title: "A new title", privacy: MessageThread::GROUP } }
        expect(response.status).to eq 401
      end
    end
  end
end
