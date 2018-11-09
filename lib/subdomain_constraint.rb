class SubdomainConstraint
  def self.matches?(request)
    request.subdomain.present? && !['www', 'www.staging'].include?(request.subdomain)
  end

  def self.subdomain(domain)
    Rails.env.staging? ? "#{domain}.staging" : "#{domain}"
  end
end
