# frozen_string_literal: true



class Ward < ApplicationRecord
  include Locatable
end

# == Schema Information
#
# Table name: wards
#
#  id       :integer          not null, primary key
#  location :geometry({:srid= not null, geometry, 4326
#  name     :string
#
# Indexes
#
#  index_wards_on_location  (location) USING gist
#
