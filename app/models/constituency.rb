# frozen_string_literal: true



class Constituency < ApplicationRecord
  include Locatable
end

# == Schema Information
#
# Table name: constituencies
#
#  id       :integer          not null, primary key
#  location :geometry({:srid= not null, geometry, 4326
#  name     :string
#
# Indexes
#
#  index_constituencies_on_location  (location) USING gist
#
