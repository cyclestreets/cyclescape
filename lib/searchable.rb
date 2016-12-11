module Searchable
  def self.included(base)
    base::SEARCHABLE_COLUMNS.each do |col|
      base.class_eval <<-EORUBY
        scope :search_by_#{col}, -> value { where("#{col} ILIKE ?", "%\#{value}%") }
      EORUBY
    end
  end
end
