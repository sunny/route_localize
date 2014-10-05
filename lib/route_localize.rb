require "route_localize/engine"
require "route_localize/extensions"
require "route_localize/route"

module RouteLocalize
  module_function

  # Yields one or several route definitions if the route definition has a
  # `localize` or `localize_subdomain` scope
  #
  # The arguments it accepts are the arguments given to
  # `ActionDispatch::Routing::RouteSet`'s method `add_route`, with the addition
  # of the `route_set` argument that should hold the current route set.
  #
  # The array it yields are the arguments accepted by `add_route` so that these
  # can be handed back to Rails to insert the yielded route.
  def translate_route(app, conditions, requirements, defaults, as, anchor, route_set)
    locales = defaults.delete(:localize) || defaults.delete(:localize_subdomain)
    if locales.present?

      # Makes sure the routes aren't created before i18n can read translations
      # This happens when gems like activeadmin call `Rails.application.reload_routes!`
      return unless I18n.load_path.grep(/routes.yml$/).any?

      locales.each do |locale|
        route = Route.new(app, conditions, requirements, defaults,
                            as, anchor, route_set, locale)
        yield *route.to_add_route_arguments
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


  # Returns a translated path
  # Example: "/trees/:id(.:format)" -> "/arbres/:id(.:format)", …
  def translated_path(path, locale, by_subdomain: false)
    path = path.dup

    # Remove "(.:format)" in routes or "?args" if used elsewhere
    final_options = path.slice!(/(\(.+\)|\?.*)$/)

    segments = path.split('/').map do |segment|
      translate_segment(segment, locale)
    end

    segments.unshift(":locale") unless by_subdomain
    segments = segments.reject(&:blank?)

    "/#{segments.join('/')}#{final_options}"
  end

  # Translates part of a path if it can
  # Example: "trees" -> "arbres", ":id" -> ":id"
  def translate_segment(segment, locale)
    if segment =~ /^[a-z_0-9]+$/i
      translation = I18n.t "routes.#{segment}", default: segment,
                                                locale: locale
      CGI.escape(translation)
    else
      segment
    end
  end
end
