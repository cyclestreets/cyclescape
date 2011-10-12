def dom_id_selector(model)
  "#" + ActionController::RecordIdentifier.dom_id(model)
end

def dom_class_selector(model)
  "." + ActionController::RecordIdentifier.dom_class(model)
end
