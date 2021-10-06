# frozen_string_literal: true

class PlanningFilter < ApplicationRecord
  STAR = "* (LAs without own rules)"

  validate :ensure_rule_is_valid_regex

  after_save :update_relevancies

  def matches?(planning_application)
    if (authority == STAR && self.class.where(authority: planning_application.authority_name).blank?) ||
       planning_application.authority_name == authority
      return Regexp.new(rule).match(planning_application.uid)
    end

    false
  end

  private

  def update_relevancies
    Resque.enqueue(SearchUpdater, :update_relevant_planning_applications)
  end

  def ensure_rule_is_valid_regex
    return unless rule

    Regexp.new rule
  rescue StandardError => e
    errors.add(:rule, e.message)
  end
end

# == Schema Information
#
# Table name: planning_filters
#
#  id         :integer          not null, primary key
#  authority  :string
#  rule       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
