require 'spec_helper'

describe PlanningFilter, type: :model do
  let(:planning_application) { build(:planning_application, uid: 'a/b/123') }

  it 'is expected to have valid regex rules' do
    subject.authority = 'West Yorkshire'
    subject.rule = '[a]'
    expect(subject).to be_valid
    subject.rule = '[a'
    expect(subject.errors_on(:rule)).to eq ['premature end of char-class: /[a/']
  end

  it 'filters irrelavant planning applications' do
    subject.authority = planning_application.authority_name
    subject.rule = '^a'
    expect(subject.matches?(planning_application)).to be_truthy
    subject.rule = '$a'
    expect(subject.matches?(planning_application)).to be_falsey
  end
end
