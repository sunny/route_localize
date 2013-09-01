Dummy::Application.routes.draw do
  get 'home', to: 'trees#home', localize: [:en, :fr]

  scope localize: [:en, :fr] do
    resources :trees, path_names: { new: "plant" }
  end

  root 'trees#index'
end
