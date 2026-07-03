ActiveSupport.on_load(:active_storage_attachment) do
  after_create_commit do
    case record
    when ActionText::RichText
      ImageVariantJob.perform_later(blob)
    when Essay, Build, FieldSeries
      ImageVariantJob.perform_later(blob) if name == "cover"
    when FieldItem
      if name == "photo"
        ImageVariantJob.perform_later(record, watermark: true)
        ExtractExifJob.perform_later(record)
      end
    end
  end
end
