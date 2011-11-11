class DatePickerInput
  include Formtastic::Inputs::Base
  include Formtastic::Inputs::Base::Stringish

  def to_html
    input_wrapping do
      label_html << builder.text_field(method, input_html_options.merge(class: "date"))
    end
  end
end
