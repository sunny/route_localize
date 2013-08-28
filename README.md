# Route Localize

Rails plugin that lets you translate routes by using a different subdomain per locale.

## Warning

For now this is unstable, with a volatile API, without enough tests,
totally not production-ready yet.

Ye be warned.


## Usage

In your Rails application's `Gemfile` add:

```rb
gem "route_localize", github: "sunny/route_localize"
```

Install the plugin by running:

```sh
$ bundle
```

In your `config/routes.rb`, localize the routes you want by surrounding them with a scope. For example:

```rb
scope localize: [:en, :fr] do
  get 'trees/new', to: 'trees#new'
end
root 'pages#index'
```

You may also specify the locales directly on the route:

```rb
get 'trees/new', localize: [:en, :fr]
```

Add translations for the route parts you want to change under the `routes` key, for example in `config/locales/routes.yml` or `config/locales/fr.yml`:

```yml
fr:
  routes:
    trees: arbres
    new: nouveau
```

Now you will have the following routes defined:

            Prefix Verb URI Pattern               Controller#Action
      trees_new_en GET /trees/new(.:format)      trees#new {:subdomain=>:en}
      trees_new_fr GET /arbres/nouveau(.:format) trees#new {:subdomain=>:fr}

You will also have the `trees_new_path` and `trees_new_url` helpers available
that use `trees_new_en` or `trees_new_fr` depending on the current locale.


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
it by creating a `localize_param` method.

This is usefull in case you would like your language switcher on
`http://en.example.org/products/keyboard` to switch to `http://fr.example.org/produits/clavier`,
where `keyboard` and `clavier` are your `:id` parameters.

The `localize_param` needs to exist in your views and takes the locale as a parameter.

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

Route Localize is different because it:

- adds a constraint to the subdomain instead of relying on the URL beeing in the url (`en/…` `fr/`)
- plays well with gems that introduce locales and routes you don't want to translate (like `active_admin`)
- includes a language switcher that lets you translate parameters in the url,
  for example if you also want to translate the article title in `/articles/1-hello-world`.

