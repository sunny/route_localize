# encoding: utf-8
require 'test_helper'

class RoutesTest < ActionDispatch::IntegrationTest
  fixtures :all

  # Mock object that acts like a routeable ActiveRecord model
  class FakeTree
    attr_reader :to_param
    def initialize(to_param)
      @to_param = to_param
    end
    def self.model_name
      self
    end
    def self.singular_route_key
      "tree"
    end
  end

  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  test "paths" do
    # en
    assert_equal "/home", home_en_path
    assert_equal "/trees/plant", new_tree_en_path
    assert_equal "/trees/42", tree_en_path(42)
    assert_equal "/trees/42/edit", edit_tree_en_path(42)

    # fr
    assert_equal "/accueil", home_fr_path
    assert_equal "/arbres/planter", new_tree_fr_path
    assert_equal "/arbres/42", tree_fr_path(42)
    assert_equal "/arbres/42/%C3%A9diter", edit_tree_fr_path(42)
  end

  test "generic paths depend on locale" do
    I18n.locale = :en
    assert_equal "/home", home_path
    assert_equal "/trees/plant", new_tree_path
    assert_equal "/trees/42", tree_path(42)
    assert_equal "http://en.example.com/trees/42", url_for(FakeTree.new(42))

    I18n.locale = :fr
    assert_equal "/accueil", home_path
    assert_equal "/arbres/planter", new_tree_path
    assert_equal "/arbres/42", tree_path(42)
    assert_equal "http://fr.example.com/arbres/42", url_for(FakeTree.new(42))
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

