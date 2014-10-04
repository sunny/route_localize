require 'spec_helper'

describe "Dummy Routes", type: "routing" do
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  it "generates named paths for each locale" do
    # en
    expect(home_en_path).to eq("/home")
    expect(new_tree_en_path).to eq("/trees/planting")
    expect(tree_en_path(42)).to eq("/trees/42")
    expect(leaf_en_path(42)).to eq("/en/leaves/42")
    expect(edit_tree_en_path(42)).to eq("/trees/42/edit")
    expect(default_fr_path).to eq("/default")

    # fr
    expect(home_fr_path).to eq("/accueil")
    expect(new_tree_fr_path).to eq("/arbres/planter")
    expect(tree_fr_path(42)).to eq("/arbres/42")
    expect(leaf_fr_path(42)).to eq("/fr/feuilles/42")
    expect(edit_tree_fr_path(42)).to eq("/arbres/42/%C3%A9diter")
    expect(default_en_path).to eq("/default")
  end

  it "generates generic named paths that depend on the current locale" do
    I18n.locale = :en
    expect(home_path).to eq("/home")
    expect(new_tree_path).to eq("/trees/planting")
    expect(tree_path(42)).to eq("/trees/42")
    expect(edit_tree_path(42)).to eq("/trees/42/edit")
    expect(leaf_path(42)).to eq("/en/leaves/42")
    expect(url_for(Tree.new(id: 42))).to eq("http://en.example.com/trees/42")
    expect(url_for(Leaf.new(id: 42))).to eq("http://example.com/en/leaves/42")
    expect(default_path).to eq("/default")

    I18n.locale = :fr
    expect(home_path).to eq("/accueil")
    expect(new_tree_path).to eq("/arbres/planter")
    expect(tree_path(42)).to eq("/arbres/42")
    expect(leaf_path(42)).to eq("/fr/feuilles/42")
    expect(edit_tree_path(42)).to eq("/arbres/42/%C3%A9diter")
    expect(url_for(Tree.new(id: 42))).to eq("http://fr.example.com/arbres/42")
    expect(url_for(Leaf.new(id: 42))).to eq("http://example.com/fr/feuilles/42")
    expect(default_path).to eq("/default")
  end

  it "generates paths depending on subdomain" do
    expect(get: "http://en.lacolhost.com/trees/42").to route_to(
      controller: "trees",
      action: "show",
      subdomain: "en",
      id: "42")

    expect(get: "http://fr.lacolhost.com/arbres/42").to route_to(
      controller: "trees",
      action: "show",
      subdomain: "fr",
      id: "42")
  end

  it "generates paths depending on url" do
    expect(get: "http://lacolhost.com/en/leaves/42").to route_to(
      controller: "leaves",
      action: "show",
      locale: "en",
      id: "42")

    expect(get: "http://lacolhost.com/fr/feuilles/42").to route_to(
      controller: "leaves",
      action: "show",
      locale: "fr",
      id: "42")
  end
end

