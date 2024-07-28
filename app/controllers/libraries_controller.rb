# frozen_string_literal: true

class LibrariesController < ApplicationController
  def show
    skip_authorization

    @items = Library::ItemDecorator.decorate_collection Library::Item.by_most_recent.page(params[:page])
  end

  def search
    skip_authorization

    items = Library::Item.search { fulltext params[:query] }
    @items = Library::ItemDecorator.decorate_collection items.results
    respond_to do |format|
      format.json { render json: @items }
    end
  end

  def relevant
    skip_authorization

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
    authorize :library
  end
end
