# frozen_string_literal: true

require "spec_helper"

describe "Global settings" do
  context "public" do
    before do
      visit root_path
    end

    it "should show the current Git version in the footer" do
      within("footer") do
        expect(page).to have_content(Rails.application.config.git_hash)
      end
    end
  end
end
