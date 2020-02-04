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
    thread = MessageThread.find(params[:thread_id])
    tag_names = thread.tags.pluck(:name)
    tag_names += thread.issue.tags.pluck(:name) if thread.issue
    items = Library::Item.search do
      paginate page: 1, per_page: 15
      any do
        tag_names.each do |tag_name|
          fulltext tag_name do
            boost_fields tags: 1.5, title: 1.5
          end
        end
      end
    end
    items = Library::ItemDecorator.decorate_collection items.results

    respond_to do |format|
      format.json { render json: items }
    end
  end

  def new
  end
end
