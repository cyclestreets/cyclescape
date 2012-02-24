require "spec_helper"

describe "Tags" do
  let(:tag) { FactoryGirl.create(:tag) }
  let!(:thread) { FactoryGirl.create(:message_thread, tags: [tag]) }
  let!(:issue) { FactoryGirl.create(:issue, tags: [tag]) }
  let!(:library_note) { FactoryGirl.create(:library_note) }
  let!(:bogus_tag) { FactoryGirl.build(:tag, name: "unfindable") }

  it "should show results" do
    library_note.item.tags = [tag]
    visit tag_path(tag)
    page.should have_content(I18n.t(".tags.show.heading", name: tag.name))
    page.should have_link(thread.title)
    page.should have_link(issue.title)
    page.should have_link(library_note.title)
  end

  it "should show an empty results page for a ficticious tag" do
    visit tag_path(bogus_tag)
    page.should have_content(I18n.t(".tags.show.heading", name: bogus_tag.name))
    page.should have_content(I18n.t(".tags.show.unrecognised", name: bogus_tag.name))
  end
end
