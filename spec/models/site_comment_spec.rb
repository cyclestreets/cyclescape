require 'spec_helper'

describe SiteComment do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:body) }

    it 'should only allow a valid URL' do
      comment = SiteComment.new
      comment.context_url = 'http://www.example.com'
      expect(comment).to have(0).errors_on(:context_url)
      comment.context_url = '/a[]d/'
      expect(comment).to have(1).error_on(:context_url)
    end

    it 'should not accept spam' do
      comment = SiteComment.new
      comment.body = 'Normal feedback without spam'
      expect(comment).to have(0).errors_on(:body)
      comment.body = "Spam <a href='www.spammylink.example.com'>link</a>"
      expect(comment).to have(1).error_on(:body)
      comment.body = "Spam [url='www.spammylink.example.com']link[/url]"
      expect(comment).to have(1).error_on(:body)
    end
  end

  context 'viewing' do
    subject { create(:site_comment) }

    it 'should update the viewed timestamp when viewed' do
      expect(subject.viewed_at).to be_nil
      subject.viewed!
      expect(subject.viewed_at).not_to be_nil
    end

    it 'should respond to viewed?' do
      expect(subject.viewed?).to be_falsey
      subject.viewed!
      expect(subject.viewed?).to be_truthy
    end
  end

  context 'deleting' do
    subject { create(:site_comment) }

    it 'should appear to be destroyed' do
      subject.destroy
      expect(SiteComment.all).to be_empty
    end

    it 'should not actually be deleted' do
      subject.destroy
      expect(SiteComment.with_deleted.length).to eql(1)
    end
  end
end
