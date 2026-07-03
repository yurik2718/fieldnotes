require "test_helper"

class SiteSettingTest < ActiveSupport::TestCase
  test "current returns the same singleton record" do
    setting = SiteSetting.current
    assert_no_difference("SiteSetting.count") do
      assert_equal setting, SiteSetting.current
    end
  end

  test "watermark_opacity must be within 10..80" do
    assert_not SiteSetting.new(watermark_opacity: 95).valid?
  end

  test "watermark_position must be a known corner" do
    assert_not SiteSetting.new(watermark_position: "center").valid?
  end
end
