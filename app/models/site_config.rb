class SiteConfig < ActiveRecord::Base
  enum timezone: []
  enum default_locale: %w(en-GB cs-CZ)
  dragonfly_accessor :logo
  dragonfly_accessor :footer1
  dragonfly_accessor :footer2
  dragonfly_accessor :footer3
end
