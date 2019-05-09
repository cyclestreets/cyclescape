# frozen_string_literal: true

module Photo
  def self.included(base)
    base.instance_eval do
      validates_size_of(:photo, maximum: 6.megabytes,
                                message: I18n.t("shared.photo.too_large"), if: :photo_changed?)
      validates_property(:format, of: :photo, in: %i[jpeg jpg png gif], case_sensitive: false,
                                  message: I18n.t("shared.photo.wrong_format"), if: :photo_changed?)
      dragonfly_accessor :photo do
        storage_options :generate_photo_path
      end

      include Base64ToDragonfly
    end
  end

  def photo_medium
    default_thumb("740x555>")
  end

  def photo_preview
    default_thumb("500x375>")
  end

  def photo_sidebar
    default_thumb("360x540>")
  end

  def photo_thumbnail
    default_thumb("50x50>")
  end

  private

  def default_thumb(resize_options)
    photo ? photo.thumb(resize_options) : nil
  end

  def storage_path
    nil
  end

  def generate_photo_path
    hash = Digest::SHA1.file(photo.path).hexdigest
    path_start = storage_path || self.class.name.underscore.pluralize
    { path: "#{path_start}/#{hash[0..2]}/#{hash[3..5]}/#{hash}" }
  end
end
