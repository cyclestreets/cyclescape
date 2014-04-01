class Library::ItemDecorator < ApplicationDecorator
  def item
    @model
  end

  def link
    h.link_to item.title, h.url_for(item.component)
  end

  def icon
    h.content_tag(:span, nil, class: "icon #{h.dom_class(item.component)}")
  end

  def created_at
    h.time_tag_with_title(item.created_at) do
      h.t('libraries.show.item_created', time_ago: h.time_ago_in_words(item.created_at))
    end
  end

  def description
    if item.component.respond_to?(:body)
      h.truncate item.component.body
    else
      ''
    end
  end

  def as_json(options = nil)
    {
      id: item.id,
      title: item.title,
      link: link,
      icon: icon,
      description: description,
      item_type: h.dom_class(item.component)
    }
  end
end
