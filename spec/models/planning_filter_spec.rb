# frozen_string_literal: true

require "spec_helper"

describe PlanningFilter, type: :model do
  let(:planning_application) { build(:planning_application, uid: "a/b/123", authority_name: "West Yorkshire") }

  it "is expected to have valid regex rules" do
    subject.authority = "West Yorkshire"
    subject.rule = "[a]"
    expect(subject).to be_valid
    subject.rule = "[a"
    expect(subject.errors_on(:rule)).to eq ["premature end of char-class: /[a/"]
  end

  it "filters irrelavant planning applications" do
    subject.authority = planning_application.authority_name
    subject.rule = "^a"
    expect(subject.matches?(planning_application)).to be_truthy
    subject.rule = "$a"
    expect(subject.matches?(planning_application)).to be_falsey
  end

  describe "star rules" do
    subject { described_class.new(authority: described_class::STAR, rule: "[a]") }

    context "when la has a rule" do
      before { described_class.create!(authority: planning_application.authority_name, rule: "[a]") }

      it "start does not match" do
        expect(subject.matches?(planning_application)).to be_falsey
      end
    end

    context "when la no rules" do
      it "start does match" do
        expect(subject.matches?(planning_application)).to be_truthy
      end
    end
  end
end
