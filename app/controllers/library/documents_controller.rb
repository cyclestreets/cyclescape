class Library::DocumentsController < ApplicationController
  before_filter :load_document, only: [:show, :download, :edit, :update, :destroy]

  def new
    @document = Library::Document.new
  end

  def create
    @document = Library::Document.new(params[:library_document])
    @document.created_by = current_user

    if @document.save!
      redirect_to library_document_path(@document)
    else
      render :new
    end
  end

  def show
    @notes = Library::ItemDecorator.decorate(@document.notes.map{ |n| n.item })
    @note = Library::Note.new_on_document(@document)
    @tag_panel = TagPanelDecorator.new(@document.item, form_url: library_tag_path(@document.item))
  end

  def edit
  end

  def update
    if @document.update_attributes(params[:document])
      redirect_to library_document_path(@document)
    else
      render :edit
    end
  end

  def destroy
    @document.destroy
    set_flash_message(:success)
    redirect_to library_path
  end

  protected

  def load_document
    @document = Library::Document.find(params[:id])
  end
end
