require 'spec_helper'

describe RouteLocalize::Route do
  subject(:route) { RouteLocalize::Route.new }

  it "is a class" do
    expect(RouteLocalize::Route).to be_kind_of Class
  end

  pending '#to_add_route_arguments'

  describe "private #translate_path" do
    it "should not modify untranslatable routes" do
      route.conditions = { required_defaults: [:localize] }
      expect(route.send(:translate_path, "/a(:b)")).to eq("/a(:b)")
      expect(route.send(:translate_path, "/a?b=c")).to eq("/a?b=c")
    end
  end
end
