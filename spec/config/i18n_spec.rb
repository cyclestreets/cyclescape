# frozen_string_literal: true

require "spec_helper"

describe "I18n error handeling" do
  it "does not swallow missing translation errors" do
    expect{ I18n.t("a.non.existing.translation.key") }.to raise_error(I18n::MissingTranslationData)
  end
end
