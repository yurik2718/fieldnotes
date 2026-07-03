class ImageVariantJob < ApplicationJob
  GALLERY_EMBED = { resize_to_limit: [ 800,  600 ] }.freeze
  FULL_EMBED    = { resize_to_limit: [ 1024, 768 ] }.freeze

  def perform(record, watermark: false)
    case record
    when ActiveStorage::Blob
      warm_variants(record)
    when FieldItem
      warm_variants(record.photo.blob) if record.photo.attached?
      apply_watermark(record) if watermark
    end
  end

  private
    def warm_variants(blob)
      return unless blob&.image?

      blob.attachments.each do |attachment|
        case attachment.record
        when ActionText::RichText
          [ GALLERY_EMBED, FULL_EMBED ].each { blob.representation(it).processed }
        else
          attachment.record.class.attachment_reflections[attachment.name].named_variants.each_key do |name|
            blob.variant(name).processed
          end
        end
      end
    end

    def apply_watermark(field_item)
      return unless field_item.photo.attached?

      setting = SiteSetting.current
      return unless setting.watermark_enabled? && setting.watermark.attached?

      field_item.photo.blob.open do |original_file|
        image = Vips::Image.new_from_file(original_file.path)
        image = composite_watermark(image, setting)
        image = image.flatten if image.has_alpha?

        Tempfile.create([ "wm", ".jpg" ]) do |tmp|
          image.write_to_file(tmp.path, Q: 90)

          field_item.watermarked_photo.attach(
            io:           File.open(tmp.path),
            filename:     "wm_#{field_item.photo.filename.base}.jpg",
            content_type: "image/jpeg"
          )
        end
      end

      warm_variants(field_item.reload.watermarked_photo.blob)
    end

    def composite_watermark(image, setting)
      setting.watermark.blob.open do |wm_file|
        watermark = Vips::Image.new_from_file(wm_file.path)

        scale     = (image.width * 0.12).to_f / watermark.width
        watermark = watermark.resize(scale)

        if watermark.bands == 4
          opacity   = setting.watermark_opacity / 100.0
          alpha     = (watermark[3] * opacity).cast(:uchar)
          watermark = watermark.extract_band(0, n: 3).bandjoin(alpha)
        end

        left, top = watermark_coords(image, watermark, setting.watermark_position)
        image.composite(watermark, :over, x: left, y: top)
      end
    end

    def watermark_coords(image, watermark, position)
      pad = 24
      case position
      when "bottom_left"  then [ pad,                                 image.height - watermark.height - pad ]
      when "top_right"    then [ image.width - watermark.width - pad, pad ]
      when "top_left"     then [ pad,                                 pad ]
      else                     [ image.width - watermark.width - pad, image.height - watermark.height - pad ]
      end
    end
end
