# encoding: utf-8
require 'test_helper'

class RoutesTest < ActionDispatch::IntegrationTest
  # fixtures :all

  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  test "generates named paths for each locale" do
    # en
    assert_equal "/home", home_en_path
    assert_equal "/trees/planting", new_tree_en_path
    assert_equal "/trees/42", tree_en_path(42)
    assert_equal "/trees/42/edit", edit_tree_en_path(42)
    assert_equal "/default", default_fr_path

    # fr
    assert_equal "/accueil", home_fr_path
    assert_equal "/arbres/planter", new_tree_fr_path
    assert_equal "/arbres/42", tree_fr_path(42)
    assert_equal "/arbres/42/%C3%A9diter", edit_tree_fr_path(42)
    assert_equal "/default", default_en_path
  end

  test "generates generic named paths that depend on the current locale" do
    I18n.locale = :en
    assert_equal "/home", home_path
    assert_equal "/trees/planting", new_tree_path
    assert_equal "/trees/42", tree_path(42)
    assert_equal "/trees/42/edit", edit_tree_path(42)
    assert_equal "http://en.example.com/trees/42", url_for(Tree.new(id: 42))
    assert_equal "/default", default_path

    I18n.locale = :fr
    assert_equal "/accueil", home_path
    assert_equal "/arbres/planter", new_tree_path
    assert_equal "/arbres/42", tree_path(42)
    assert_equal "/arbres/42/%C3%A9diter", edit_tree_path(42)
    assert_equal "http://fr.example.com/arbres/42", url_for(Tree.new(id: 42))
    assert_equal "/default", default_path
  end

  test "generates paths depending on subdomain" do
    # en
    assert_routing("http://en.lacolhost.com/trees/42",
                   { controller: "trees", action: "show", subdomain: "en", id: "42" },
                   { subdomain: "en" })

    # fr

    # FIXME : assert_routing points to /trees/42
    # assert_routing("http://fr.lacolhost.com/arbres/42",
    #                { controller: "trees", action: "show", subdomain: "fr", id: "42" },
    #                subdomain: "fr")

    assert_recognizes({ controller: "trees", action: "show", subdomain: "fr", id: "42" },
                      "http://fr.lacolhost.com/arbres/42",
                      { subdomain: "fr" })
  end

end

