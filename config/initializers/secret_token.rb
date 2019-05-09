# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
fallback_token = "a1bcbfb276fb310924d6c5f8c7ca23d880200b"

# check for the existence of a config/secret_token file, which we generate for produtions systems.

# TODO: remove secret_file (this is now secret key base)
secret_key_base = Rails.root.join("config", "secret_token")

if Rails.env.production?
  Rails.application.config.secret_token = File.read(secret_key_base).strip
  Rails.application.config.secret_key_base = File.read(secret_key_base).strip
else
  Rails.application.config.secret_token = fallback_token
  Rails.application.config.secret_key_base = fallback_token
end
