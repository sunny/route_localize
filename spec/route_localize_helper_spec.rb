require 'spec_helper'

describe RouteLocalizeHelper, type: "helper" do
  let(:current_route_name) { "bang" }
  let(:route) { double(:route, name: current_route_name) }

  before do
    RSpec::Mocks.configuration.verify_partial_doubles = false

    # Mock routing internals
    allow(Rails.application.routes).to receive(:recognize_path) { nil }
    allow(Rails.application.routes.router).to receive(:recognize)
      .and_yield(route, nil)
  end

  describe '#locale_switch_url' do
    let(:url) { "http://example.com/bang" }
    let(:fr_url) { "http://example.com/fr/bang" }
    let(:en_url) { "http://example.com/en/bang" }
    let(:fr_root_url) { "http://example.com/fr" }
    let(:en_root_url) { "http://example.com/en" }

    before do
      allow(helper).to receive(:bang_fr_url).with(locale: :fr) { fr_url }
      allow(helper).to receive(:bang_en_url).with(locale: :en) { en_url }
      allow(helper).to receive(:root_url).with(locale: :fr) { fr_root_url }
      allow(helper).to receive(:root_url).with(locale: :en) { en_root_url }
    end

    it "finds the locale url by using the localized url helper" do
      expect(helper.locale_switch_url(:fr)).to eq(fr_url)
      expect(helper.locale_switch_url(:en)).to eq(en_url)
    end

    context "with no current route name" do
      let(:current_route_name) { nil }

      it "defaults to root url" do
        expect(helper.locale_switch_url(:fr)).to eq(fr_root_url)
        expect(helper.locale_switch_url(:en)).to eq(en_root_url)
      end
    end

    context "without a localized url helper" do
      before do
        allow(helper).to receive(:respond_to?).and_call_original
        allow(helper).to receive(:respond_to?).with("bang_fr_url") { false }
      end

      it "falls back to using a normal non-localized url" do
        allow(helper).to receive(:bang_url).with(locale: :fr) { "foo" }
        expect(helper.locale_switch_url(:fr)).to eq("foo")
      end
    end

    context "without a localized url or normal url helper" do
      before do
        allow(helper).to receive(:respond_to?).and_call_original
        allow(helper).to receive(:respond_to?).with("bang_fr_url") { false }
        allow(helper).to receive(:respond_to?).with("bang_url") { false }
      end

      it "falls back to using the root url" do
        expect(helper.locale_switch_url(:fr)).to eq(fr_root_url)
      end
    end

    context "when route_localize_path_options is defined" do
      before do
        allow(helper).to receive(:route_localize_path_options) {
          { foo: "bar" }
        }
      end

      it "passes extra parameters to the url helper" do
        allow(helper).to receive(:bang_fr_url)
          .with(locale: :fr, foo: "bar") { "foobar" }
        expect(helper.locale_switch_url(:fr)).to eq("foobar")
      end
    end

    context "when the get route is not reckognised" do
      before do
        expect(Rails.application.routes).to receive(:recognize_path)
          .with(fr_url, method: :get)
          .and_raise(ActionController::RoutingError.new(nil, nil))
      end

      it "falls back to root_url" do
        expect(helper.locale_switch_url(:fr)).to eq(fr_root_url)
      end
    end
  end


  describe '#locale_switch_subdomain_url' do
    let(:url) { "http://example.com/bang" }
    let(:fr_url) { "http://fr.example.com/bang" }
    let(:en_url) { "http://en.example.com/bang" }
    let(:fr_root_url) { "http://fr.example.com/" }
    let(:en_root_url) { "http://en.example.com/" }

    before do
      allow(helper).to receive(:bang_fr_url).with(subdomain: :fr) { fr_url }
      allow(helper).to receive(:bang_en_url).with(subdomain: :en) { en_url }
      allow(helper).to receive(:root_url).with(subdomain: :fr) { fr_root_url }
      allow(helper).to receive(:root_url).with(subdomain: :en) { en_root_url }
    end

    it "finds the locale url by using the localized url helper" do
      expect(helper.locale_switch_subdomain_url(:fr)).to eq(fr_url)
      expect(helper.locale_switch_subdomain_url(:en)).to eq(en_url)
    end
  end
end
