require 'test_helper'

class RoutesTest < ActionDispatch::IntegrationTest
  fixtures :all

  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  test "paths" do
    assert_equal "/home", home_en_path
    assert_equal "/accueil", home_fr_path
  end

  test "paths depending on locale" do
    I18n.locale = :en
    assert_equal "/home", home_path
    I18n.locale = :fr
    assert_equal "/accueil", home_path
  end

  test "paths depending on subdomain" do
    host! "en.localhost.com"
    assert_generates "/home", controller: "trees", action: "home"
    host! "fr.localhost.com"
    assert_generates "/accueil", controller: "trees", action: "home"
  end
end

