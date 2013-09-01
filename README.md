# Route Localize

Rails 4 engine Rails 4 engine to to translate routes using locale files and subdomains.

## Warning

Here be dragons.

For now this is unstable, with a volatile API, without enough tests,
totally not production-ready yet, version `0.0.1`.


## Install

In your Rails application's `Gemfile` add:

```rb
gem "route_localize", github: "sunny/route_localize"
```

Install the plugin by running:

```sh
$ bundle
```

## Usage

In your `config/routes.rb`, localize the routes you want by surrounding them with a scope. For example:

```rb
scope localize: [:en, :fr] do
  get 'trees/new', to: 'trees#new'
end
root 'pages#index'
```

Create a `config/locales/routes.yml` with translations for each part of your routes under the `routes` key. For example:

```yml
fr:
  routes:
    trees: arbres
    new: nouveau
```

With this example you would have the following routes defined:

            Prefix Verb URI Pattern               Controller#Action
      trees_new_en GET /trees/new(.:format)      trees#new {:subdomain=>:en}
      trees_new_fr GET /arbres/nouveau(.:format) trees#new {:subdomain=>:fr}

You also get the `trees_new_path` and `trees_new_url` helpers that will call
`trees_new_en` or `trees_new_fr` depending on the current locale.


## Language switcher

If you want to be able to switch to the current page in another language
add the following inside your `app/helpers/application_helper.rb`:

```rb
module ApplicationHelper
  include RouteLocalizeHelper
end
```

You can then use the `locale_switch_url` helper in your views:

```erb
<%= link_to "fr", locale_switch_url("fr") %>
<%= link_to "en", locale_switch_url("en") %>
```

### Localize the `:id` parameter in your switcher

If your `:id` param is different depending on the language, you can override
it by creating a `localize_param` method that takes the locale as a parameter.

This is usefull in case you would like your language switcher on
`http://en.example.org/products/keyboard` to switch to `http://fr.example.org/produits/clavier`,
where `keyboard` and `clavier` are your `:id` parameters.

For example if your controller did this:

```rb
class ProductsController < ApplicationController
  def show
    if I18n.locale = "fr"
      @tree = Product.find_by_name_fr(params[:id])
    else
      @tree = Product.find_by_name_en(params[:id])
    end
  end
end
```

Then you would need to add this inside your controller:

```
  helper_method :localize_param
  def localize_param(locale)
    locale == "fr" ? @tree.name_fr : @tree.name_en
  end
```


## Other gems to translate Rails routes

The following gems could be a good match for your project:

- [translate_routes](https://github.com/raul/translate_routes)
- [route_translator](https://github.com/enriclluelles/route_translator/)
- [rails-translate-routes](https://github.com/francesc/rails-translate-routes/)
- [routing-filter](https://github.com/svenfuchs/routing-filter)

Route Localize is different because it:

- adds a constraint to the subdomain instead of relying on the locale beeing in the url (`en/…` `fr/`)
- plays well with gems that introduce extra locales, routes you don't want to translate, or reload routes before i18n is loaded (`activeadmin` for example)
- includes a powerfull language switcher helper.

