require 'test_helper'

class RouteLocalizeTest < ActiveSupport::TestCase
  test "RouteLocalize exists" do
    assert_kind_of Module, RouteLocalize
  end

  test "translate_path should not change routes" do
    assert_equal "/a(:b)", RouteLocalize::Route.new.send(:translate_path, "/a(:b)", "fr")
    assert_equal "/a?b=c", RouteLocalize::Route.new.send(:translate_path, "/a?b=c", "fr")
  end
end
