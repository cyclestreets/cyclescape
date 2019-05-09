# frozen_string_literal: true

shared_context "with subdomain", use: :subdomain do
  def set_subdomain(subdomain)
    @original_default_host = Capybara.default_host
    Capybara.default_host = "http://#{subdomain}.example.com"
  end

  def unset_subdomain
    Capybara.default_host = @original_default_host
  end
end

shared_context "with current group subdomain", use: :current_subdomain do
  include_context "with subdomain"

  before { set_subdomain(current_group.short_name) }
  after  { unset_subdomain }
end
