# frozen_string_literal: true

# == Schema Information
#
# Table name: user_prefs
#
#  id                      :integer          not null, primary key
#  user_id                 :integer          not null
#  involve_my_locations    :string(255)      default("subscribe"), not null
#  involve_my_groups       :string(255)      default("notify"), not null
#  involve_my_groups_admin :boolean          default(FALSE), not null
#  enable_email            :boolean          default(FALSE), not null
#  zz_profile_visibility   :string(255)      default("public"), not null
#
# Indexes
#
#  index_user_prefs_on_enable_email             (enable_email)
#  index_user_prefs_on_involve_my_groups        (involve_my_groups)
#  index_user_prefs_on_involve_my_groups_admin  (involve_my_groups_admin)
#  index_user_prefs_on_involve_my_locations     (involve_my_locations)
#  index_user_prefs_on_user_id                  (user_id) UNIQUE
#

class UserPref < ActiveRecord::Base
  # ---> CONSTANTS
  EmailStatus = Struct.new(:id, :status) do
    def label
      I18n.t("email_status.#{status}")
    end
  end
  class_attribute :email_statuses
  self.email_statuses = [
    EmailStatus.new(0, :no_email),
    EmailStatus.new(1, :email),
    EmailStatus.new(2, :digest),
  ].index_by(&:id).freeze

  belongs_to :user

  INVOLVEMENT_OPTIONS = %w(none notify subscribe)

  validates :involve_my_locations, inclusion: { in: INVOLVEMENT_OPTIONS }
  validates :involve_my_groups, inclusion: { in: INVOLVEMENT_OPTIONS }
  validates :email_status_id, inclusion: email_statuses.keys

  def enable_email?
    email_status_id == 1
  end

end
