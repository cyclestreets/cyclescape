require 'spec_helper'

Dir[Rails.root.join("app", "models", "messages", "**", "*.rb")].each { |f| require f }

describe ThreadListDecorator, type: :decorator do
  let(:thread) { build_stubbed :message_thread }

  subject { described_class.decorate_collection([thread]) }

  it "has the component_name translated" do
    MessageComponent.descendants.each do |klass|
      message = build_stubbed :message
      allow(message).to receive(:component).and_return(klass.new)
      allow(thread).to receive(:latest_message).and_return(message)
      subject[0].latest_activity
    end
  end
end
