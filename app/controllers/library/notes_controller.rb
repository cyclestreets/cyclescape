class Library::NotesController < ApplicationController
  before_filter :load_note, except: [:new, :create]

  def new
    @note = Library::Note.new
  end

  def create
    @note = Library::Note.new(params[:library_note])
    @note.created_by = current_user

    if @note.save
      redirect_to library_note_path(@note)
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @note.update_attributes(params[:library_note])
      set_flash_message(:success)
      redirect_to library_note_path(@note)
    else
      render :edit
    end
  end

  def destroy
    @note.destroy
    redirect_to library_path
  end

  protected

  def load_note
    @note = Library::Note.find(params[:id])
  end
end
