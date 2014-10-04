require 'test_helper'

class RouteTest < ActiveSupport::TestCase
  test "RouteLocalize::Route exists" do
    assert_kind_of Class, RouteLocalize::Route
  end

  # to_add_route_arguments

  test "private translate_path should not change routes" do
    route = RouteLocalize::Route.new
    assert_equal "/a(:b)", route.send(:translate_path, "/a(:b)")
    assert_equal "/a?b=c", route.send(:translate_path, "/a?b=c")
  end
end
