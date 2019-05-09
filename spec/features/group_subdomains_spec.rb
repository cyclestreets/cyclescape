# frozen_string_literal: true

require "spec_helper"

describe "Group subdomains", use: :subdomain do
  context "valid domains" do
    let(:group) { create(:group) }

    before do
      set_subdomain(group.short_name)
    end

    after { unset_subdomain }

    context "accessed as a public user" do
      it "should show the group page at the root" do
        visit "/"
        expect(page).to have_content(group.name)
      end

      it "should have the subdomain in the URL" do
        visit "/"
        expect(page.current_host).to eq("http://#{group.short_name}.example.com")
      end

      it "should not override the group page (bug)" do
        other_group = create(:group)
        visit group_path(other_group)
        expect(page).to have_content(other_group.name)
      end
    end
  end

  context "invalid domains" do
    before do
      set_subdomain("invalid")
    end

    after { unset_subdomain }

    it "should redirect you to www" do
      visit "/"
      expect(page.current_host).to eq("http://www.example.com")
    end

    it "should redirect you to www on other pages too" do
      visit "/issues"
      expect(page.current_host).to eq("http://www.example.com")
    end
  end
end
