# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
secret_token = 'a1bcbfb276fb310924d6c5f8c7ca23d880200baf4bfe99a3769e2e889eedf6dd941d293f4d82fd38487da6fedbb71076d01ccf6f630ae64326a84d32ba2526ce'

# check for the existence of a config/secret_token file, which we generate for produtions systems.
secret_file = File.expand_path('../../secret_token', __FILE__)
Cyclescape::Application.config.secret_token = File.exists?(secret_file) ? File.read(secret_file).strip : secret_token
