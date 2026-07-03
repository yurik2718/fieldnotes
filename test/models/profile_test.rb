require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  test "instance returns the same singleton record" do
    profile = Profile.instance
    assert_no_difference("Profile.count") do
      assert_equal profile, Profile.instance
    end
  end

  test "requires a name" do
    assert_not Profile.new(name: "").valid?
  end
end
