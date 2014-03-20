# == Schema Information
#
# Table name: site_comments
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  name         :string(255)
#  email        :string(255)
#  body         :text             not null
#  context_url  :string(255)
#  context_data :text
#  created_at   :datetime         not null
#  viewed_at    :datetime
#

require 'spec_helper'

describe SiteComment do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:body) }

    it 'should only allow a valid URL' do
      comment = SiteComment.new
      comment.context_url = 'http://www.example.com'
      comment.should have(0).errors_on(:context_url)
      comment.context_url = 'blah'
      comment.should have(1).error_on(:context_url)
    end

    it 'should not accept spam' do
      comment = SiteComment.new
      comment.body = 'Normal feedback without spam'
      comment.should have(0).errors_on(:body)
      comment.body = "Spam <a href='www.spammylink.example.com'>link</a>"
      comment.should have(1).error_on(:body)
      comment.body = "Spam [url='www.spammylink.example.com']link[/url]"
      comment.should have(1).error_on(:body)
    end
  end

  context 'viewing' do
    subject { FactoryGirl.create(:site_comment) }

    it 'should update the viewed timestamp when viewed' do
      subject.viewed_at.should be_nil
      subject.viewed!
      subject.viewed_at.should_not be_nil
    end

    it 'should respond to viewed?' do
      subject.viewed?.should be_false
      subject.viewed!
      subject.viewed?.should be_true
    end
  end
end
