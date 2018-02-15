# frozen_string_literal: true

module AttributeNormaliser
  class URL
    def initialize(val)
      @val = val.respond_to?(:strip) ? val.strip : val
    end

    def normalise
      if @val.blank? || @val =~ %r{\A.*://}
        @val
      else
        "http://#{@val}"
      end
    end
  end
end
