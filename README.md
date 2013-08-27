# RouteLocalize

RouteLocalize to be able to translate routes using locale files and subdomains.

## Rationale

- https://github.com/enriclluelles/route_translator/
- https://github.com/francesc/rails-translate-routes/

## Usage

- Add `route_localize.rb` and the `route_localize` folder to `lib`
- In your `config/routes.rb`, add a `require 'route_localize'`
- Localize the routes you want by surrounding them with a scope :

      scope localize: [:en, :fr] do
        get 'trees/new', to: 'trees#new'
      end
      root_path to: 'pages#index'

- In a `config/locales/routes.yml`, add:

      fr:
        routes:
          trees: arbres
          new: nouveau

Now you will have the following routes defined:

            Prefix Verb URI Pattern               Controller#Action
      trees_new_en GET /trees/new(.:format)      trees#new {:subdomain=>:en}
      trees_new_fr GET /arbres/nouveau(.:format) trees#new {:subdomain=>:fr}

And both `trees_new_path` and `trees_new_url` helpers are created to return
the path for the current locale.

## Language switcher

If you want to be able to switch to the current page in another language
add the following inside your `app/helpers/application_helper.rb`:

    require 'route_localize/helper'
    module ApplicationHelper
      include RouteLocalize::Helper
    end

You can then use the `locale_switch_url` in your views:

    <%= link_to "fr", locale_switch_url("fr") %>

### Hijack the `:id` parameter

If your `:id` param is different depending on the language, you can override
it by creating a `localize_param` helper.

For example in your controller:

    class TreesController < ApplicationController
      def show
        if I18n.locale = "fr"
          @tree = Tree.find_by_name_fr(params[:id])
        else
          @tree = Tree.find_by_name_en(params[:id])
        end
      end

      helper_method :localize_param
      def localize_param(locale)
        if locale == "fr"
          @tree.name_fr
        else
          @tree.name_en
        end
      end
    end

### Tests

To define a subdomain in rspec:

    before(:each) do
      request.host = "fr.xip.io"
    end
