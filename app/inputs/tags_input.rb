class TagsInput
  include Formtastic::Inputs::Base
  include Formtastic::Inputs::Base::Stringish

  def to_html
    input_wrapping do
      label_html << builder.text_field(method, input_html_options.merge(class: "tags"))
    end
  end
end
