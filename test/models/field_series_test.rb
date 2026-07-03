require "test_helper"

class FieldSeriesTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    series = FieldSeries.new(title: "Patagonia 2026", slug: "patagonia-2026", kind: "photo")
    assert series.valid?
  end

  test "kind must be photo, video, or mixed" do
    series = FieldSeries.new(title: "X", slug: "x", kind: "audio")
    assert_not series.valid?
  end

  test "has many field_items" do
    series = field_series(:iceland)
    assert series.field_items.any?
  end

  test "destroying series destroys items" do
    series = field_series(:iceland)
    item_count = series.field_items.count
    assert_difference("FieldItem.count", -item_count) { series.destroy }
  end

  # --- Slug auto-generation ---
  test "auto-generates slug from title" do
    series = FieldSeries.new(title: "Japan 2026", kind: "photo")
    series.valid?
    assert_equal "japan-2026", series.slug
  end

  test "handles duplicate slugs for series" do
    FieldSeries.create!(title: "Mountains", kind: "photo")
    second = FieldSeries.create!(title: "Mountains", kind: "video")
    assert_equal "mountains-2", second.slug
  end

  test "cover_photo is nil without cover or item photos" do
    assert_nil field_series(:iceland).cover_photo
  end

  test "cover_photo falls back to the first item photo" do
    series = field_series(:iceland)
    item = series.field_items.ordered.first
    item.photo.attach(io: File.open(file_fixture("test_image.jpg")), filename: "a.jpg", content_type: "image/jpeg")

    assert_equal item.photo.blob, series.reload.cover_photo.blob
  end

  test "cover_photo prefers the series cover" do
    series = field_series(:iceland)
    series.cover.attach(io: File.open(file_fixture("test_image.jpg")), filename: "c.jpg", content_type: "image/jpeg")

    assert_equal series.cover.blob, series.cover_photo.blob
  end

  test "append_photos creates positioned photo items" do
    series = field_series(:norway)
    photos = 2.times.map do
      { io: File.open(file_fixture("test_image.jpg")), filename: "a.jpg", content_type: "image/jpeg" }
    end

    assert_difference("FieldItem.count", 2) do
      series.append_photos(photos)
    end

    assert_equal [ 2, 3 ], series.field_items.ordered.last(2).map(&:position)
    assert series.field_items.ordered.last(2).all?(&:photo?)
  end
end
