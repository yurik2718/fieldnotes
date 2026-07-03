require "test_helper"

class AnalyticsSubscriberTest < ActiveSupport::TestCase
  test "creates page_view on essay.viewed event" do
    assert_difference("PageView.count", 1) do
      Rails.event.notify("essay.viewed", essay_id: 1, path: "/essays/test")
    end
  end

  test "creates page_view on field.viewed event" do
    assert_difference("PageView.count", 1) do
      Rails.event.notify("field.viewed", series_id: 1, path: "/field/iceland-2026")
    end
  end

  test "stores only the event payload, not the envelope" do
    Rails.event.notify("essay.viewed", essay_id: 7, path: "/essays/x")

    view = PageView.last.reload
    assert_equal "essay.viewed", view.event
    assert_equal 7, view.payload["essay_id"]
    assert_equal %w[ essay_id path ], view.payload.keys.sort
  end

  test "ignores untracked events" do
    assert_no_difference("PageView.count") do
      Rails.event.notify("some.other.event", foo: "bar")
    end
  end
end
