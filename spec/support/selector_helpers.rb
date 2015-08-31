def dom_id_selector(model)
  '#' + ActionView::RecordIdentifier.dom_id(model)
end

def dom_class_selector(model)
  '.' + ActionView::RecordIdentifier.dom_class(model)
end
