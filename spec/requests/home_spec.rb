require "spec_helper"

describe "Home page" do
  it "should have the intro text" do
    visit root_path
    page.should have_content(I18n.t("home.show.introduction_html"))
  end

  it "should have a report issue button" do
    visit root_path
    page.should have_link("Report an issue")
  end

  context "discussions" do
    it "should list 6 discussions"
    it "should be ordered by most recent first"
    it "should not contain private discussions"
  end
end
