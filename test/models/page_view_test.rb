require "test_helper"

class PageViewTest < ActiveSupport::TestCase
  test "valid with event name" do
    pv = PageView.new(event: "essay.viewed", payload: { essay_id: 1 })
    assert pv.valid?
  end

  test "invalid without event" do
    pv = PageView.new(payload: { essay_id: 1 })
    assert_not pv.valid?
  end

  test "payload stores JSON" do
    pv = PageView.create!(event: "essay.viewed", payload: { essay_id: 42, path: "/essays/test" })
    assert_equal 42, pv.reload.payload["essay_id"]
  end

  test "prune deletes views older than a year and keeps recent ones" do
    old = PageView.create!(event: "essay.viewed")
    old.update_column(:created_at, 2.years.ago)
    recent = PageView.create!(event: "essay.viewed")

    PageView.prune

    assert_not PageView.exists?(old.id)
    assert PageView.exists?(recent.id)
  end
end
