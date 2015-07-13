require 'spec_helper'

describe 'Site feedback' do
  before do
    visit root_path
  end

  context 'as a public user' do
    it 'should be able to see the feedback link' do
      expect(page).to have_link('Feedback')
    end

    it 'should be able to send feedback' do
      click_on 'Feedback'
      fill_in 'Message', with: 'Your site is awesome!'
      fill_in 'Name', with: 'Bobby Jones'
      fill_in 'Email', with: 'bobby@example.com'
      click_on 'Send Feedback'
      expect(page).to have_content('Thank you')
    end

    it 'should store the request URL with the comment' do
      click_on 'Feedback'
      fill_in 'Message', with: 'This page broke!'
      click_on 'Send Feedback'
      expect(SiteComment.last.context_url).to eq(root_url)
    end
  end

  context as: :site_user do
    include_context 'signed in as a site user'

    it 'should not let you browse the feedback' do
      visit site_comments_path
      expect(page).to have_content('You are not authorised to access that page.')
    end
  end

  context as: :admin do
    let!(:comment) { create(:site_comment) }
    include_context 'signed in as admin'

    it 'should show the comments' do
      visit site_comments_path
      expect(page).to have_content(comment.body[0..51]) # chokes on newline
    end

    it 'should allow deleting' do
      expect(SiteComment.count).to eql(1)
      visit site_comments_path
      click_on I18n.t('.site.comments.index.delete_comment')
      expect(page).to have_content(I18n.t('.site.comments.destroy.success'))
      expect(SiteComment.count).to eql(0)
    end
  end
end
