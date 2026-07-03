class ExtractExifJob < ApplicationJob
  def perform(field_item)
    return unless field_item.photo.attached?

    field_item.photo.open do |file|
      data = read_exif(file.path)
      next unless data

      field_item.update!(
        camera_make:   data["Make"],
        camera_model:  data["Model"],
        lens:          data["LensModel"] || data["Lens"],
        focal_length:  data["FocalLength"]&.to_s,
        aperture:      data["FNumber"] ? "f/#{data["FNumber"]}" : nil,
        shutter_speed: data["ExposureTime"]&.to_s,
        iso:           data["ISO"]&.to_i,
        taken_at:      parse_exif_date(data["DateTimeOriginal"]),
        gps_latitude:  data["GPSLatitude"],
        gps_longitude: data["GPSLongitude"]
      )

      if field_item.position == 1 && data["GPSLatitude"] && field_item.field_series.latitude.blank?
        field_item.field_series.update!(
          latitude:  data["GPSLatitude"],
          longitude: data["GPSLongitude"]
        )
      end
    end
  end

  private
    def read_exif(path)
      JSON.parse(IO.popen([ "exiftool", "-j", "-n", path ], &:read))&.first
    end

    def parse_exif_date(value)
      return unless value
      Time.strptime(value, "%Y:%m:%d %H:%M:%S")
    rescue ArgumentError
      nil
    end
end
