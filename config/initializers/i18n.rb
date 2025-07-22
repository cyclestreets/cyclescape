# frozen_string_literal: true

# config/initializers/i18n.rb

module I18n
  class JustRaiseExceptionHandler < ExceptionHandler
    def call(exception, locale, key, options)
      if exception.is_a?(MissingTranslation) || exception.is_a?(MissingTranslationData)
        raise exception.to_exception
      end

      super
    end
  end
end

I18n.exception_handler = I18n::JustRaiseExceptionHandler.new if Rails.env.test?
