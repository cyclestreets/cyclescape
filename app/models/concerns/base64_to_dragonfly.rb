module Base64ToDragonfly
  extend ActiveSupport::Concern

  included do
    dragonfly_attachment_classes.map(&:attribute).each do |attr|
      define_method("base64_#{attr}") {}
      define_method("base64_#{attr}=") do |base64|
        return nil if base64.blank?
        decoded_image = Base64.decode64(base64.split(",")[1])
        begin
          temp_image = Tempfile.new "temp_image"
          temp_image.binmode
          temp_image.write(decoded_image)
        ensure
          temp_image.close
        end
        public_send("#{attr}=", temp_image)
      end
    end
  end
end
