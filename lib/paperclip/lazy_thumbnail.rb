# frozen_string_literal: true

module Paperclip
  class LazyThumbnail < Paperclip::Processor
    class PixelGeometryParser
      def self.parse(current_geometry, pixels)
        width  = Math.sqrt(pixels * (current_geometry.width.to_f / current_geometry.height)).round.to_i
        height = Math.sqrt(pixels * (current_geometry.height.to_f / current_geometry.width)).round.to_i

        Paperclip::Geometry.new(width, height)
      end
    end

    def initialize(file, options = {}, attachment = nil)
      super

      @crop = options[:geometry].to_s[-1, 1] == '#'
      @current_geometry = options.fetch(:file_geometry_parser, Geometry).from_file(@file)
      @target_geometry = options[:pixels] ? PixelGeometryParser.parse(@current_geometry, options[:pixels]) : options.fetch(:string_geometry_parser, Geometry).parse(options[:geometry].to_s)
      @format = options[:format]
      @current_format = File.extname(@file.path)
    end

    def make
      source = File.open(@file.path)

      return source unless needs_convert?

      vips = ImageProcessing::Vips.source(source)

      vips = if @crop
               vips.resize_to_fill(@target_geometry.width, @target_geometry.height, sharpen: false, crop: :attention)
             else
               vips.resize_to_limit(@target_geometry.width, @target_geometry.height, sharpen: false)
             end

      vips = vips.custom do |image|
        image.mutate do |mutable|
          image.get_fields.each do |field|
            mutable.remove!(field) unless field == 'icc-profile-data'
          end
        end
      end

      vips.convert(@format)
          .saver(interlace: true, quality: 90)
          .call
    end

    private

    def needs_convert?
      needs_different_geometry? || needs_different_format? || needs_metadata_stripping?
    end

    def needs_different_geometry?
      (options[:geometry] && @current_geometry.width != @target_geometry.width && @current_geometry.height != @target_geometry.height) ||
        (options[:pixels] && @current_geometry.width * @current_geometry.height > options[:pixels])
    end

    def needs_different_format?
      @format.present? && @current_format != @format
    end

    def needs_metadata_stripping?
      @attachment.instance.respond_to?(:local?) && @attachment.instance.local?
    end
  end
end
