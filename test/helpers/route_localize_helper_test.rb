require 'test_helper'

class RouteLocalizeHelperTest < ActiveSupport::TestCase
  include RouteLocalizeHelper

  test "locale_switch_url" do
    assert_equal "foo", locale_switch_url("en")
  end
end
