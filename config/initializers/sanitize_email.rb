# frozen_string_literal: true

if defined? SanitizeEmail
  staging_email_address = %w[staging-email cyclescape.org].join("@")

  SanitizeEmail::Config.configure do |config|
    config[:sanitized_to] = staging_email_address
    config[:sanitized_cc] = staging_email_address
    config[:sanitized_bcc] = staging_email_address
    config[:activation_proc] = proc { !Rails.env.production? }
    config[:use_actual_email_prepended_to_subject] = true
    config[:use_actual_environment_prepended_to_subject] = true
    config[:use_actual_email_as_sanitized_user_name] = true
  end
end
