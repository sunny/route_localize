require 'test_helper'

class RoutesTest < ActionDispatch::IntegrationTest
  fixtures :all

  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  test "paths" do
    # en
    assert_equal "/home", home_en_path
    assert_equal "/trees/new", new_tree_en_path

    # fr
    assert_equal "/accueil", home_fr_path
    assert_equal "/arbres/nouveau", new_tree_fr_path
  end

  test "generic paths depend on locale" do
    I18n.locale = :en
    assert_equal "/home", home_path
    assert_equal "/trees/new", new_tree_path

    I18n.locale = :fr
    assert_equal "/accueil", home_path
    assert_equal "/arbres/nouveau", new_tree_path
  end

  test "generates paths depending on subdomain" do
    # en
    assert_routing("http://en.lacolhost.com/trees/42",
                   { controller: "trees", action: "show", subdomain: "en", id: "42" },
                   { subdomain: "en" })

    # fr
    assert_recognizes({ controller: "trees", action: "show", subdomain: "fr", id: "42" },
                      "http://fr.lacolhost.com/arbres/42",
                      { subdomain: "fr" })
    # FIXME
    # Rails always seems to generate /trees/42 instead
    # assert_routing("http://fr.lacolhost.com/arbres/42",
    #                { controller: "trees", action: "show", subdomain: "fr", id: "42" },
    #                subdomain: "fr")
  end

end

