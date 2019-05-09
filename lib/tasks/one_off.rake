# frozen_string_literal: true

namespace :one_off do
  task fix_image_ext: :environment do
    update = lambda do |has_dragonfly, method|
      begin
        next if has_dragonfly.public_send(method).meta["name"].split(".").size > 1

        fmt = has_dragonfly.public_send(method).format
        next unless fmt&.present?

        new_path = "#{has_dragonfly.public_send(method).path}.#{fmt}"
        FileUtils.cp(has_dragonfly.public_send(method).path, new_path)
        has_dragonfly.public_send("#{method}=", File.open(new_path))
        has_dragonfly.save!
        FileUtils.rm(new_path)
      rescue Dragonfly::Job::Fetch::NotFound
      end
    end

    [CyclestreetsPhotoMessage, PhotoMessage, Issue].each do |klass|
      scope = klass.where.not(photo_uid: nil)
      progressbar = ProgressBar.new(scope.count)
      scope.find_each do |has_photo|
        progressbar.increment!
        update.call(has_photo, :photo)
      end
    end

    [UserProfile, GroupProfile].each do |klass|
      scope = klass.where.not(picture_uid: nil)
      progressbar = ProgressBar.new(scope.count)
      scope.find_each do |has_picture|
        progressbar.increment!
        update.call(has_picture, :picture)
      end
    end
  end
end
