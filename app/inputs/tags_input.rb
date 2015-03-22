class TagsInput
  include Formtastic::Inputs::Base
  include Formtastic::Inputs::Base::Stringish
  include Rails3JQueryAutocomplete::Autocomplete

  def to_html
    input_wrapping do
      # FIXME: Need to switch to using a _path instead of a hardcoded string.
      # As soon as I introduce include ActionController::UrlWriter and autocomplete_tags_path instead
      # of a hard coded string, it barfs with Formtastic::UnknownInputError in Issues#new which I don't know how to resolve.
      label_html << builder.autocomplete_field(method, '/tags/autocomplete_tag_name', input_html_options.merge(class: 'tags', :"data-delimiter" => ' '))
    end
  end
end
