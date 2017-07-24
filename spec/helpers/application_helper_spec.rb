require 'spec_helper'

describe ApplicationHelper, type: :helper do
  let(:thread)  { create :message_thread }
  let(:issue)   { create :issue, title: 'Important issue' }
  let(:group)    { build_stubbed :group }
  let(:message_thread) { build_stubbed(:message_thread, group: group) }
  let(:message) { build(:message, body: body, thread: message_thread) }
  let(:body) { "This #{format} is #useful" }
  let(:group_url) { "http://#{group.short_name}.test.host" }

  include ApplicationHelper

  shared_examples 'links the thread' do
    it 'links the thread' do

      expect(message_linkify(message)).
        to eq "This <a href=\"/threads/#{thread.id}\">#{format}</a> is <a class=\"hashtag\" href=\"#{group_url}/hashtags/useful\">#useful</a>"
    end
  end

  shared_examples 'links the issue' do
    it 'links the thread' do
      expect(message_linkify(message)).
        to eq "This <a href=\"/issues/#{issue.id}-important-issue\">#{format}</a> is<a class=\"hashtag\" href=\"#{group_url}/hashtags/useful\">#useful</a>"
    end
  end

  describe 'message linkification' do
    context 'with thread :number format' do
      let(:format) { "thread #{thread.id}" }
      include_examples 'links the thread'
    end

    context 'with thread no :number format' do
      let(:format) { "thread no #{thread.id}" }
      include_examples 'links the thread'
    end

    context 'with thread no. :number format' do
      let(:format) { "thread no. #{thread.id}" }
      include_examples 'links the thread'
    end

    context 'with thread number :number format' do
      let(:format) { "thread no. #{thread.id}" }
      include_examples 'links the thread'
    end

    context 'with thread #:number format' do
      let(:format) { "thread ##{thread.id}" }
      include_examples 'links the thread'
    end

    context 'with multiple formats' do
      let(:format) { "issue no #{issue.id}, issue #{issue.id}, thread #{thread.id}" }

      it 'does not link the issue' do
        expect(message_linkify(message)).to eq(
          "This <a href=\"/issues/#{issue.id}-important-issue\">issue no #{issue.id}</a>, <a href=\"/issues/#{issue.id}-important-issue\">issue #{issue.id}</a>, <a href=\"/threads/#{thread.id}\">thread #{thread.id}</a> is <a class=\"hashtag\" href=\"#{group_url}/hashtags/useful\">#useful</a>"
        )
      end
    end

  end
end
