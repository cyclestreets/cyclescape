# frozen_string_literal: true


class UserProfile < ApplicationRecord
  VISIBILITY_OPTIONS = %w[public group].freeze

  dragonfly_accessor :picture do
    storage_options :generate_picture_path
  end

  include Base64ToDragonfly

  Locale = Struct.new(:id, :label, :locale)
  class_attribute :all_locales
  self.all_locales = [
    Locale.new(0, "English - UK", "en-GB"),
    Locale.new(1, "Deutsch (Deutschland)", "de-DE"),
    Locale.new(2, "Česká - Česká republika", "cs-CZ"),
    Locale.new(3, "Italiano", "it")
  ].index_by(&:id).freeze

  enum locale: all_locales.values.each_with_object({}).each { |loc, memo| memo[loc.locale] = loc.id }

  belongs_to :user

  validates :website, url: true
  validates :visibility, inclusion: { in: VISIBILITY_OPTIONS }

  normalize_attribute :website, with: :url

  def picture_thumbnail
    picture.thumb("50x50>")
  end

  def clear
    update(picture: nil, website: nil, about: nil, locale: nil)
  end

  protected

  def generate_picture_path
    hash = Digest::SHA1.file(picture.path).hexdigest
    { path: "profile_pictures/#{hash[0..2]}/#{hash[3..5]}/#{hash}" }
  end
end

# == Schema Information
#
# Table name: user_profiles
#
#  id          :integer          not null, primary key
#  about       :text
#  locale      :integer
#  picture_uid :string(255)
#  visibility  :string(255)      default("public"), not null
#  website     :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  user_id     :integer          not null
#
# Indexes
#
#  index_user_profiles_on_user_id  (user_id)
#
