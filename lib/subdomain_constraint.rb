# frozen_string_literal: true

class SubdomainConstraint
  def self.matches?(request)
    request_subdomain = subdomain_from_request(request)
    request_subdomain.present? && !["www", "www.staging"].include?(request_subdomain)
  end

  def self.subdomain_from_request(request)
    if Rails.env.development?
      domains = request.domain.split(".")
      if domains.size > 1
        domains[0]
      end
    else
      request.subdomain.split(".")[0]
    end
  end

  def self.subdomain(domain)
    Rails.env.staging? ? "#{domain}.staging" : domain.to_s
  end
end
