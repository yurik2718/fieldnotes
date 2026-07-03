require "test_helper"

class PositionedTest < ActiveSupport::TestCase
  test "assigns next position on create" do
    build = Build.create!(title: "Next Build", status: "active", kind: "oss")
    assert_equal Build.where.not(id: build.id).maximum(:position) + 1, build.position
  end

  test "keeps explicitly assigned position" do
    build = Build.create!(title: "Explicit", status: "active", kind: "oss", position: 42)
    assert_equal 42, build.position
  end

  test "positions field items within their own series" do
    third_in_iceland = field_series(:iceland).field_items.create!(kind: "photo")
    assert_equal 3, third_in_iceland.position

    second_in_norway = field_series(:norway).field_items.create!(kind: "photo")
    assert_equal 2, second_in_norway.position
  end
end
