require 'spec_helper'

describe RouteLocalize do
  let(:args) { [app, conditions, requirements, defaults, as, anchor, route_set] }
  let(:app) { double(:app) }
  let(:conditions) { { required_defaults: [:localize], path_info: "/bang" } }
  let(:requirements) { [:localize] }
  let(:defaults) { {} }
  let(:as) { "bang" }
  let(:anchor) { double(:anchor) }
  let(:route_set) { double(:route_set, named_routes: named_routes) }
  let(:named_routes) { double(:named_routes, routes: {}, module: route_module) }
  let(:route_module) { double(:module, define_method: nil) }


  describe '.translate_route' do
    context "with no localization" do
      let(:defaults) { { foo: "bar" } }

      it "yields once" do
        expect { |b| RouteLocalize.translate_route(*args, &b) }.to \
          yield_control.once
      end

      it "yields the given args except for route_set" do
        expected_args = [app, conditions, requirements, defaults, as, anchor]
        expect { |b| RouteLocalize.translate_route(*args, &b) }.to \
          yield_with_args(*expected_args)
      end

      it "does not define locale helpers" do
        RouteLocalize.translate_route(*args) { }
        expect(route_module).not_to have_received(:define_method)
      end
    end

    context "with localize by subdomain" do
      let(:defaults) { { localize: [:en, :fr] } }

      it "yields twice" do
        expect { |b| RouteLocalize.translate_route(*args, &b) }.to \
          yield_control.twice
      end

      it "defines path and url helpers" do
        RouteLocalize.translate_route(*args) { }
        expect(route_module).to have_received(:define_method).twice
        expect(route_module).to have_received(:define_method).with("bang_path")
        expect(route_module).to have_received(:define_method).with("bang_url")
      end
    end
  end

  describe '.define_locale_helpers' do
    let(:helper) { double(:helper, define_method: nil) }

    before do
      # Spy on the generated methods beeing called
      RSpec::Mocks.configuration.verify_partial_doubles = false
      allow(RouteLocalize).to receive(:bang_fr_url)
      allow(RouteLocalize).to receive(:bang_fr_path)
      allow(RouteLocalize).to receive(:bang_en_url)
      allow(RouteLocalize).to receive(:bang_en_path)

      # Store the methods defined
      @bang_path = @bang_url = nil
      expect(helper).to receive(:define_method).with("bang_path") { |&m| @bang_path = m }
      expect(helper).to receive(:define_method).with("bang_url") { |&m| @bang_url = m }
    end

    it "defines path in each locale" do
      RouteLocalize.define_locale_helpers("bang", helper)

      I18n.locale = :fr
      @bang_path.call
      expect(RouteLocalize).to have_received(:bang_fr_path).once

      I18n.locale = :en
      @bang_path.call
      expect(RouteLocalize).to have_received(:bang_en_path).once
    end

    it "defines methods that call the path and url of the current locale" do
      RouteLocalize.define_locale_helpers("bang", helper)

      # When in french, call the french methods
      I18n.locale = :fr
      @bang_path.call
      expect(RouteLocalize).to have_received(:bang_fr_path).once
      @bang_url.call
      expect(RouteLocalize).to have_received(:bang_fr_url).once

      # When in english, call the english methods
      I18n.locale = :en
      @bang_path.call
      expect(RouteLocalize).to have_received(:bang_en_path).once
      @bang_url.call
      expect(RouteLocalize).to have_received(:bang_en_url).once
    end
  end
end
