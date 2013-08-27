# RouteLocalize

Rails plugin to be able to translate routes using a different subdomain per locale
and translations in locale files.


## Warning

This is unstable, totally not production-ready yet. Ye be warned.


## Usage

In your Rails application's `Gemfile` add:

    gem "route_localize", github: "sunny/route_localize"

Install the plugin by running:

    $ bundle

Localize the routes you want by surrounding them with a scope. For example :

    scope localize: [:en, :fr] do
      get 'trees/new', to: 'trees#new'
    end
    
    root 'pages#index'

In a `config/locales/routes.yml`, add:

      fr:
        routes:
          trees: arbres
          new: nouveau

Now you will have the following routes defined:

            Prefix Verb URI Pattern               Controller#Action
      trees_new_en GET /trees/new(.:format)      trees#new {:subdomain=>:en}
      trees_new_fr GET /arbres/nouveau(.:format) trees#new {:subdomain=>:fr}

You will also have the helpers `trees_new_path` and `trees_new_url` available
that use `trees_new_en` or `trees_new_fr` depending on the current locale.


## Language switcher

If you want to be able to switch to the current page in another language
add the following inside your `app/helpers/application_helper.rb`:

    module ApplicationHelper
      include RouteLocalizeHelper
    end

You can then use the `locale_switch_url` helper in your views:

    <%= link_to "fr", locale_switch_url("fr") %>
    <%= link_to "en", locale_switch_url("en") %>

### Hijack the `:id` parameter

If your `:id` param is different depending on the language, you can override
it by creating a `localize_param` method.

This is usefull in case you would like your language switcher on
`http://en.example.org/products/keyboard` to switch to `http://fr.example.org/produits/clavier`,
where `keyboard` and `clavier` are your `:id` parameters.

The `localize_param` needs to exist in your views and takes the locale as a parameter.

For example if your controller did this:

    class ProductsController < ApplicationController
      def show
        if I18n.locale = "fr"
          @tree = Product.find_by_name_fr(params[:id])
        else
          @tree = Product.find_by_name_en(params[:id])
        end
      end
    end

Then you would need to add this inside your controller:

      helper_method :localize_param
      def localize_param(locale)
        locale == "fr" ? @tree.name_fr : @tree.name_en
      end



## Other good gems

Before builind this I considered using the following gems :

- [translate_routes](https://github.com/raul/translate_routes)
- [route_translator](https://github.com/enriclluelles/route_translator/)
- [rails-translate-routes](https://github.com/francesc/rails-translate-routes/)

All three rely on the locale beeing in the url (`en/…` `fr/`), don't add constraints to the subdomain.

These gems didn't seem to play with gems like `active_admin` that introduce a lot of new locales or whose routes
you don't want to translate.

None had a language switcher that lets you go translate parameters in the url, for example when
you want to translate the article title in `/articles/1-hello-world`.
