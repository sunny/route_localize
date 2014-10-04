require "route_localize/engine"
require "route_localize/extensions"
require "route_localize/route"

module RouteLocalize
  module_function

  # Yields one or several routes if the route definition has a `localize:` scope
  def translate_route(app, conditions, requirements, defaults, as, anchor, route_set)
    locales = defaults.delete(:localize) || defaults.delete(:localize_url)
    if locales.present?

      # Makes sure the routes aren't loaded before i18n can read translations
      # This happens when gems like `activeadmin` call `Rails.application.reload_routes!`
      return unless I18n.load_path.grep(/routes.yml$/).any?

      locales.each do |locale|
        route = Route.new(locale, app, conditions, requirements, defaults,
                            as, anchor, route_set)
        yield *route.route_args
      end

      define_locale_helpers(as, route_set.named_routes.module)
    else
      yield app, conditions, requirements, defaults, as, anchor
    end
  end

  # Create _path and _url helpers for the given path name
  # that uses I18n.locale to pick the current path
  def define_locale_helpers(name, helper)
    %w(url path).each do |method|
      helper.send :define_method, "#{name}_#{method}" do |*args|
        send("#{name}_#{I18n.locale}_#{method}", *args)
      end
    end
  end

end
