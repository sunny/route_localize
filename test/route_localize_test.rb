require 'test_helper'

class RouteLocalizeTest < ActiveSupport::TestCase
  test "RouteLocalize exists" do
    assert_kind_of Module, RouteLocalize
  end

  test "translate_path should not change routes" do
    route = RouteLocalize::Route.new
    assert_equal "/a(:b)", route.send(:translate_path, "/a(:b)")
    assert_equal "/a?b=c", route.send(:translate_path, "/a?b=c")
  end
end
