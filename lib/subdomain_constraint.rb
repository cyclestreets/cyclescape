# frozen_string_literal: true

class SubdomainConstraint
  def self.matches?(request)
    request_subdomain = subdomain_from_request(request)
    request_subdomain.present? && !["www", "www.staging"].include?(request_subdomain)
  end

  def self.subdomain_from_request(request)
    if Rails.env.development? || Rails.env.test?
      return request.subdomain if request.subdomain.present?

      # There are lots of hosts test request can have:
      #   Rails controllers use ActionDispatch::TestRequest ENV which is test.host
      #   Capybara can uses 127.0.0.1 (i.e. the request.domain is nil)
      #   Or localhost as JS specs are driving Capybara in a seaprate thread so
      #   we can add a subdomain.localhost which still hits the Rails test app
      return if !request.domain || request.domain == ActionDispatch::TestRequest.create.env["HTTP_HOST"]

      domains = request.domain.split(".")
      domains[0] if domains.size > 1
    else
      request.subdomain.split(".")[0]
    end
  end

  def self.subdomain(domain)
    Rails.env.staging? ? "#{domain}.staging" : domain.to_s
  end
end
