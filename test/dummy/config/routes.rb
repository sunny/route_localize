Dummy::Application.routes.draw do
  get 'home', to: 'trees#home', localize: %w(en fr)

  scope localize: [:en, :fr] do
    resources :trees, path_names: { new: "plant" }

    get "default", to: "trees#home"
  end


  scope ':locale', localize_url: [:en, :fr] do
    resources :leaves
  end

  root "trees#index"
end
