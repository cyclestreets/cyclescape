# == Schema Information
#
# Table name: external_services
#
#  id                     :integer          not null, primary key
#  name                   :string(255)      not null
#  short_name             :string(255)      not null
#
# Indexes
#
#  index_external_services_on_short_name  (short_name)
#

class ExternalService < ActiveRecord::Base
  has_many :threads, class_name: 'MessageThread', inverse_of: :external_service

  validates :name, presence: true, uniqueness: true
  validates :short_name, presence: true, uniqueness: true, subdomain: true

  normalize_attributes :short_name, with: [:strip, :blank, :downcase]

  def to_param
    "#{id}-#{short_name}"
  end

  protected
end
