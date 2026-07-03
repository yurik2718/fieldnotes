require "test_helper"

class ExtractExifJobTest < ActiveSupport::TestCase
  test "extracts EXIF data from photo" do
    item = field_items(:photo_one)
    item.photo.attach(io: File.open(file_fixture("test.jpg")), filename: "test.jpg", content_type: "image/jpeg")

    exif_data = { "Make" => "Sony", "Model" => "A7III", "LensModel" => "24-70mm f/2.8",
                  "FocalLength" => 35.0, "FNumber" => 2.8, "ExposureTime" => 0.008,
                  "ISO" => 400, "DateTimeOriginal" => "2026:03:15 10:30:00",
                  "GPSLatitude" => 64.1466, "GPSLongitude" => -21.9426 }

    job = ExtractExifJob.new
    job.define_singleton_method(:read_exif) { |_path| exif_data }
    job.perform(item)

    item.reload
    assert_equal "Sony", item.camera_make
    assert_equal "A7III", item.camera_model
    assert_equal "24-70mm f/2.8", item.lens
    assert_equal "f/2.8", item.aperture
    assert_equal 400, item.iso
  end

  test "skips if no photo attached" do
    item = field_items(:video_one)
    assert_nothing_raised { ExtractExifJob.perform_now(item) }
  end

  test "auto-fills series coordinates from first photo" do
    series = field_series(:iceland)
    series.update!(latitude: nil, longitude: nil)
    item = series.field_items.find_by(position: 1)
    item.photo.attach(io: File.open(file_fixture("test.jpg")), filename: "test.jpg", content_type: "image/jpeg")

    exif_data = { "GPSLatitude" => 64.1466, "GPSLongitude" => -21.9426 }

    job = ExtractExifJob.new
    job.define_singleton_method(:read_exif) { |_path| exif_data }
    job.perform(item)

    series.reload
    assert_in_delta 64.1466, series.latitude.to_f, 0.001
    assert_in_delta(-21.9426, series.longitude.to_f, 0.001)
  end
end
