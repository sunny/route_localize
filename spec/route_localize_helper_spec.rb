require 'spec_helper'

describe RouteLocalizeHelper, type: "helper" do
  it "responds to locale_switch_url" do
    expect(helper).to respond_to(:locale_switch_url)
  end

  pending '#locale_switch_url'
end
