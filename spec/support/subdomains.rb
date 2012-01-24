shared_context "with subdomain", use: :subdomain do
  def set_subdomain(subdomain)
    @original_default_host = Capybara.default_host
    Capybara.default_host = "http://#{subdomain}.example.com"
  end

  def unset_subdomain
    Capybara.default_host = @original_default_host
  end
end
