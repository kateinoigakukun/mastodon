# frozen_string_literal: true

module Paperclip
  class BlurhashTranscoder < Paperclip::Processor
    def make
      return @file unless options[:style] == :small || options[:blurhash]

      image = Vips::Image.new_from_file(@file.path, access: :sequential)

      attachment.instance.blurhash = Blurhash.encode(image.width, image.height, image.to_a.flatten, **(options[:blurhash] || {}))

      @file
    end
  end
end
