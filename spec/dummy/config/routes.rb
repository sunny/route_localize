Dummy::Application.routes.draw do
  get 'home', to: 'trees#home', localize_subdomain: %w(en fr)

  scope localize: [:en, :fr] do
    resources :leaves
  end

  scope localize_subdomain: [:en, :fr] do
    resources :trees, path_names: { new: "plant" }

    get "default", to: "trees#home"
  end

  root "trees#index"
end
