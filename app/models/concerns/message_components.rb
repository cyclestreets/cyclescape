# frozen_string_literal: true

module MessageComponents
  def component_name
    self.class.name.underscore
  end

  def notification_name
    "new_#{component_name}".to_sym
  end
end
