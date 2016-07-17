class Library::NotesController < ApplicationController
  before_filter :load_note, except: [:new, :create]
  filter_access_to [:edit, :update], attribute_check: true, load_method: :load_note

  def new
    @note = Library::Note.new
    @start_location = current_user.start_location
  end

  def create
    @note = Library::Note.new permitted_params
    @note.created_by = current_user

    if @note.save
      if @note.document?
        redirect_to library_document_path @note.document
      else
        redirect_to library_note_path @note
      end
    else
      set_location
      render :new
    end
  end

  def show
    @tag_panel = TagPanelDecorator.new(@note.item, form_url: library_tag_path(@note.item), auth_context: :library_tags)
    @threads = @note.item.threads.is_public.order_by_latest_message.limit 10
    @item = Library::ItemDecorator.decorate @note.item
  end

  def edit
    set_location
  end

  def update
    if @note.update permitted_params
      set_flash_message :success
      redirect_to library_note_path @note
    else
      set_location
      render :edit
    end
  end

  def destroy
    @note.destroy
    redirect_to library_path
  end

  protected

  def set_location
    @start_location = @note.location || current_user.start_location
  end

  def load_note
    @note = Library::Note.find params[:id]
  end

  def permitted_params
    params.require(:library_note).permit :tags_string, :body, :library_document_id, :title, :loc_json
  end
end
