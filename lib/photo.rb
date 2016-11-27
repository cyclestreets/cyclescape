module Photo
  def self.included(base)
    base.instance_eval do
      dragonfly_accessor :photo do
        storage_options :generate_photo_path
      end
    end
  end

  def photo_medium
    photo.thumb('740x555>')
  end

  def photo_preview
    photo.thumb('500x375>')
  end

  def photo_sidebar
    photo.thumb('360x540>')
  end

  def photo_thumbnail
    photo.thumb('50x50>')
  end

  private

  def storage_path
    nil
  end

  def generate_photo_path
    hash = Digest::SHA1.file(photo.path).hexdigest
    path_start = storage_path || self.class.name.underscore.pluralize
    {path: "#{path_start}/#{hash[0..2]}/#{hash[3..5]}/#{hash}"}
  end
end
