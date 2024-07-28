# frozen_string_literal: true

class Library::DocumentsController < ApplicationController
  before_action :load_document, only: %i[show download edit update destroy]

  def new
    @document = Library::Document.new
    authorize @document
    @start_location = current_user.start_location
  end

  def create
    @document = Library::Document.new permitted_params
    @document.created_by = current_user
    authorize @document

    if @document.save
      redirect_to library_document_path @document
    else
      set_location
      render :new
    end
  end

  def show
    skip_authorization
    @notes = Library::ItemDecorator.decorate_collection(@document.notes.map(&:item))
    @note = Library::Note.new_on_document @document
    @tag_panel = TagPanelDecorator.new(@document.item, form_url: library_tag_path(@document.item))
    @threads = @document.item.threads.is_public.order_by_latest_message.limit 10
    @item = Library::ItemDecorator.decorate @document.item
  end

  def edit
    set_location
  end

  def update
    if @document.update permitted_params
      redirect_to library_document_path @document
    else
      set_location
      render :edit
    end
  end

  def destroy
    @document.destroy
    set_flash_message :success
    redirect_to library_path
  end

  protected

  def load_document
    @document = Library::Document.find params[:id]
    authorize @document unless action_name == "show" # No auth needed for show?
    @document
  end

  def set_location
    @start_location = @document.location || current_user.start_location
  end

  def permitted_params
    params.require(:library_document).permit :title, :file, :retained_file, :tags_string, :loc_json
  end
end
