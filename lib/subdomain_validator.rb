class SubdomainValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return unless value.present?
    reserved_names = %w(www ftp mail pop smtp admin ssl sftp imap munin dev files test svn m proxied iframe hosted api)
    if reserved_names.include?(value)
      object.errors[attribute] << 'cannot be a reserved name'
    end

    object.errors[attribute] << 'must have between 1 and 63 letters' unless (1..63) === value.length
    object.errors[attribute] << 'cannot start with a hyphen' unless value =~ /^[^-]/i
    object.errors[attribute] << 'cannot end with a hyphen' unless value =~ /[^-]$/i
    object.errors[attribute] << 'must be lower-case alphanumeric; a-z, 0-9' unless value =~ /^[a-z0-9]+$/
  end
end
