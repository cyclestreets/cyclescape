require 'spec_helper'

describe MessagesController, type: :controller do
  describe 'create' do
    let(:message) { build :message }
    let(:groups) { [] }
    let(:user) { create :user, groups: groups }
    let(:thread_to_user) { nil }
    let(:thread) { create :message_thread, privacy: privacy, user: thread_to_user }
    let(:privacy) { "public" }
    subject { post :create, message: message.attributes, thread_id: thread.id }
    before do
      warden.set_user user
    end
    let!(:akismet_req) do
      stub_request(:post, /rest\.akismet\.com\/1\.1\/comment-check/).
        with(body: {blog: "http://www.cyclescape.org/",
                     comment_author: user.full_name,
                     comment_author_email: user.email,
                     comment_content: message.body,
                     comment_type: "comment",
                     is_test: "1"}).to_return(status: 200, body: is_spam)
    end

    context 'with a spam like message' do
      let(:is_spam) { 'true' }

      it 'redirect to thread and display flash' do
        expect(subject).to redirect_to("/threads/#{thread.id}")
        expect(akismet_req).to have_been_made
        expect(flash[:alert]).to eq(t('possible_spam'))
      end

      it 'adds the message (and not the thread) to the mod queue' do
        expect{subject}.to change{Message.mod_queued.count}.by(1)
        expect(thread.reload.approved?).to eq true
      end

      context "with a private message" do
        let(:privacy) { "private" }
        let(:groups) { [create(:group)] }
        let(:thread_to_user) { create :user, groups: groups }

        it 'does not check for spam' do
          expect{subject}.to_not change { Message.mod_queued.count }
          expect(flash[:alert]).to be_blank
        end
      end
    end

    context 'with a normal message' do
      let(:is_spam) { 'false' }
      it 'redirect to thread' do
        expect(subject).to redirect_to("/threads/#{thread.id}")
        expect(akismet_req).to have_been_made
        expect(flash[:alert]).to be_blank
      end
    end
  end

  describe 'approve' do
    let(:message)          { create(:message, :possible_spam, thread: message_thread) }
    let(:message_thread)   { create(:message_thread, :belongs_to_group) }
    let(:group)            { message_thread.group }
    let(:committee_member) { create(:user).tap{ |usr| create(:group_membership, :committee, user: usr, group: group) } }
    let(:other_user)       { create(:group_membership, :committee).user }

    before do
      warden.set_user user_type
    end

    subject { put :approve, id: message.id, thread_id: message_thread.id, format: :js }

    context 'for a committee member' do
      let!(:req)      { stub_request(:post, /rest\.akismet\.com\/1\.1\/submit-ham/).to_return(status: 200) }
      let(:user_type) { committee_member }

      it { expect(subject.status).to eq(200) }
      it { subject; expect(req).to have_been_made }
    end

    context 'for a non committee member' do
      let(:user_type) { other_user }
      it { expect(subject.status).to eq(401) }
    end
  end
end
