# frozen_string_literal: true

# config/initializers/i18n.rb
# https://github.com/svenfuchs/i18n/issues/123

module I18n
  module Backend
    module Pluralization
      # Overriding the pluralization method so if the proper plural form is missing we will try
      # to fallback to the default gettext plural form (which is the `germanic` one).
      def pluralize(locale, entry, count)
        return entry unless entry.is_a?(Hash) && count

        pluralizer = pluralizer(locale)
        if pluralizer.respond_to?(:call)
          return entry[:zero] if count == 0 && entry.key?(:zero)

          plural_key = pluralizer.call(count)
          return entry[plural_key] if entry.key?(plural_key)

          # fallback to the default gettext plural forms if real entry is missing (for example :few)
          default_gettext_key = count == 1 ? :one : :other
          return entry[default_gettext_key] if entry.key?(default_gettext_key)

          # If nothing is found throw the classic exception
          raise InvalidPluralizationData.new(entry, count)
        else
          super
        end
      end
    end
  end

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
