module AttributeNormaliser
  class URL
    def initialize(val)
      @val = val
    end

    def normalise
      if @val.nil? or @val =~ %r{\A.*://}
        @val
      else
        "http://#{@val}"
      end
    end
  end
end
