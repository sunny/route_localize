require "route_localize/engine"
require "route_localize/extensions"

module RouteLocalize
  extend self

  # Create _path and _url helpers for the given path name
  # that uses I18n.locale to pick the current path
  def define_locale_helpers(name, helper)
    %w(url path).each do |method|
      helper.send :define_method, "#{name}_#{method}" do |*args|
        ret = send("#{name}_#{I18n.locale}_#{method}", *args)
        Rails.logger.info "#{name}_#{method} => #{name}_#{I18n.locale}_#{method} => #{ret}"
        ret
      end
    end
  end

  # Translate part of a path
  def translate_segment(segment, locale)
    if segment =~ /^[a-z_]+$/
      translation = I18n.t segment, default: segment, locale: locale, scope: "routes"
      CGI.escape(translation)
    else
      segment
    end
  end

  # Translate a route's path
  def translate_path(path, locale)
    path = path.dup
    final_optional_segments = path.slice!(/(\(.+\))$/)
    segments = path.split('/').map do |segment|
      translate_segment(segment, locale)
    end
    "#{segments.join('/')}#{final_optional_segments}"
  end

  # Yields one or several routes if the route definition has a `localize:` scope
  def translate_route(app, conditions, requirements, defaults, as, anchor, route_set)
    if defaults[:localize]
      locales = defaults.delete(:localize)
      locales.each do |locale|
        # Name
        locale_as = "#{as}_#{locale}"
        locale_as = nil if route_set.named_routes.routes[locale_as.to_sym]

        # Path
        locale_conditions = conditions.dup
        locale_conditions[:path_info] = translate_path(locale_conditions[:path_info], locale)
        locale_conditions[:subdomain] = locale.to_s
        locale_conditions[:required_defaults] = locale_conditions[:required_defaults].reject { |l| l == :localize }

        # Other arguments
        locale_defaults = defaults.merge(subdomain: locale.to_s)

        yield app, locale_conditions, requirements, locale_defaults, locale_as, anchor
      end

      define_locale_helpers(as, route_set.named_routes.module)
    else
      yield app, conditions, requirements, defaults, as, anchor
    end
  end
end
