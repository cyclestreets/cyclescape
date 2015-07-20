class ApplicationDecorator < Draper::Decorator
  # Set the correct authorizaton context from the model class name when
  # automatically called from permitted_to? in views.
  def self.decl_auth_context
    source_class.name.tableize.to_sym
  end
  delegate_all

  def self.collection_decorator_class
    PaginatingDecorator
  end
  # Lazy Helpers
  #   PRO: Call Rails helpers without the h. proxy
  #        ex: number_to_currency(model.price)
  #   CON: Add a bazillion methods into your decorator's namespace
  #        and probably sacrifice performance/memory
  #
  #   Enable them by uncommenting this line:
  #   lazy_helpers

  # Shared Decorations
  #   Consider defining shared methods common to all your models.
  #
  #   Example: standardize the formatting of timestamps
  #
  #   def formatted_timestamp(time)
  #     h.content_tag :span, time.strftime("%a %m/%d/%y"),
  #                   :class => 'timestamp'
  #   end
  #
  #   def created_at
  #     formatted_timestamp(model.created_at)
  #   end
  #
  #   def updated_at
  #     formatted_timestamp(model.updated_at)
  #   end
end
