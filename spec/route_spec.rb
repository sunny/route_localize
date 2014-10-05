require 'spec_helper'

describe RouteLocalize::Route do

  it "is a class" do
    expect(RouteLocalize::Route).to be_kind_of Class
  end

  describe '#to_add_route_arguments' do
    let(:app) { double(:app) }
    let(:conditions) { { required_defaults: [:localize_subdomain], path_info: "/bang" } }
    let(:requirements) { [:localize_subdomain] }
    let(:defaults) { {} }
    let(:as) { "bang" }
    let(:anchor) { double(:anchor) }
    let(:route_set) { double(:route_set, named_routes: named_routes) }
    let(:named_routes) { double(:named_routes, routes: {}) }

    let(:route) do
      RouteLocalize::Route.new(app, conditions, requirements, defaults, as,
                               anchor, route_set, :fr)
    end

    before do
      I18n.backend.store_translations(:fr, { routes: {
        the: "le",
        big: "grand",
        bang: "boum",
      }})
    end

    it "returns a translated route by subdomain" do
      conditions = { required_defaults: [], path_info: "/boum", subdomain: "fr" }
      defaults = { subdomain: "fr" }
      as = "bang_fr"

      expect(route.to_add_route_arguments).to eq(
        [app, conditions, requirements, defaults, as, anchor])
    end

    it "returns a translated route by url" do
      conditions = { required_defaults: [], path_info: "/:locale/boum", locale: "fr" }
      defaults = { locale: "fr" }
      as = "bang_fr"

      route.conditions[:required_defaults] = [:localize]
      expect(route.to_add_route_arguments).to eq(
        [app, conditions, requirements, defaults, as, anchor])
    end

    it "translates parts of routes" do
      route.conditions[:path_info] = "/the/big/bang"
      path = route.to_add_route_arguments[1][:path_info]
      expect(path).to eq("/le/grand/boum")
    end

    it "does not modify optional routes" do
      route.conditions[:path_info] = "/the(:big)"
      path = route.to_add_route_arguments[1][:path_info]
      expect(path).to eq("/le(:big)")
    end

    it "does not modify route params" do
      route.conditions[:path_info] = "/the?big=bang"
      path = route.to_add_route_arguments[1][:path_info]
      expect(path).to eq("/le?big=bang")
    end
  end
end
