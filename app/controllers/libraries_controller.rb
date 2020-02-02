# frozen_string_literal: true

class LibrariesController < ApplicationController
  def show
    @items = Library::ItemDecorator.decorate_collection Library::Item.by_most_recent.page(params[:page])
  end

  def search
    items = Library::Item.search { fulltext params[:query] }
    @items = Library::ItemDecorator.decorate_collection items.results
    respond_to do |format|
      format.json { render json: @items }
    end
  end

  def relevant
    issue = Issue.find(params[:issue_id])
    tag_names = issue.tags.pluck(:name)
    items = Library::Item.search do
      paginate page: 1, per_page: 15
      any do
        tag_names.each do |tag_name|
          fulltext tag_name do
            boost_fields tags: 1.5
          end
        end
      end
    end
    items = Library::ItemDecorator.decorate_collection items.results
    render json: items
  end

  def new
  end
end
