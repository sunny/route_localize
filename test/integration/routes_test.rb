require 'test_helper'

class RoutesTest < ActionDispatch::IntegrationTest
  fixtures :all

  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  test "paths" do
    assert_equal "/home", home_en_path
    assert_equal "/accueil", home_fr_path
  end

  test "generic paths depend on locale" do
    I18n.locale = :en
    assert_equal "/home", home_path
    I18n.locale = :fr
    assert_equal "/accueil", home_path
  end

  test "generates paths depending on subdomain" do
    # EN
    assert_routing("http://en.lacolhost.com/trees/42",
                   { controller: "trees", action: "show", subdomain: "en", id: "42" },
                   { subdomain: "en" })

    # FR
    assert_recognizes({ controller: "trees", action: "show", subdomain: "fr", id: "42" },
                      "http://fr.lacolhost.com/arbres/42",
                      { subdomain: "fr" })

    # TODO Rails always seems to generate /trees/42 instead
    # assert_routing("http://fr.lacolhost.com/arbres/42",
    #                { controller: "trees", action: "show", subdomain: "fr", id: "42" },
    #                subdomain: "fr")
  end

end

