# frozen_string_literal: true

def dom_id_selector(model)
  "#" + ActionView::RecordIdentifier.dom_id(model)
end

def dom_class_selector(model)
  "." + ActionView::RecordIdentifier.dom_class(model)
end

def tinymce_fill_in(with:, id: "message_body")
  page.find("#message_body", visible: false)

  # wait until the TinyMCE editor instance is ready. This is required for cases
  # where the editor is loaded via XHR.
  sleep 0.1 until page.evaluate_script("tinyMCE.get('#{id}') !== null")

  js = "tinyMCE.get('#{id}').setContent('#{with.tr("'", "\\\\'")}')"
  page.execute_script(js)
end
