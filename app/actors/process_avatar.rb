require "image_processing/mini_magick"

class ProcessAvatar < Actor
  input :file

  output :processed_file

  def call
    return if file.blank?

    processed = ImageProcessing::MiniMagick
      .source(file.tempfile)
      .resize_to_fill(200, 200)
      .saver(quality: 80)
      .call

    self.processed_file = {
      io: File.open(processed.path),
      filename: "avatar.jpg",
      content_type: "image/jpeg"
    }
  end
end
