require 'spec_helper'

describe RouteLocalize::Route do
  subject(:route) { RouteLocalize::Route.new }

  it "is a class" do
    expect(RouteLocalize::Route).to be_kind_of Class
  end

  pending '#to_add_route_arguments'

  describe "private #translate_path" do
    it "should not modify optional routes" do
      route.conditions = { required_defaults: [:localize], path_info: "/a(:b)" }
      expect(route.send(:translated_path)).to eq("/a(:b)")
    end

    it "should not modify route params"
      route.conditions = { required_defaults: [:localize], path_info: "/a?b=c" }
      expect(route.send(:translated_path)).to eq("/a?b=c")
    end
  end
end
