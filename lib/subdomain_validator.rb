# frozen_string_literal: true

class SubdomainValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return if value.blank?

    reserved_names = %w[www ftp mail pop smtp admin ssl sftp imap munin dev files test svn m proxied iframe hosted api issuemap staging blog]
    object.errors.add(attribute, "cannot be a reserved name") if reserved_names.include?(value)

    object.errors.add(attribute, "must have between 1 and 63 letters") unless (1..63) === value.length
    # We've removed hyphens from our implementation, but they would otherwise be valid in the middle of the subdomain.
    # object.errors[attribute] << 'cannot start with a hyphen' unless value =~ /^[^-]/i
    # object.errors[attribute] << 'cannot end with a hyphen' unless value =~ /[^-]$/i
    object.errors.add(attribute, "must be lower-case alphanumeric; a-z, 0-9") unless value =~ /^[a-z0-9]+$/
  end
end
