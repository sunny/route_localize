require "route_localize/engine"
require "route_localize/extensions"

module RouteLocalize
  extend self

  # Yields one or several routes if the route definition has a `localize:` scope
  def translate_route(app, conditions, requirements, defaults, as, anchor, route_set)

    if defaults[:localize]
      # Makes sure the routes aren't loaded before i18n can read translations
      # This happens when gems like `activeadmin` call `Rails.application.reload_routes!`
      return unless I18n.load_path.grep(/routes.yml$/).any?

      locales = defaults.delete(:localize)
      locales.each do |locale|
        yield *route_args_for_locale(locale, app, conditions, requirements, defaults, as, anchor, route_set)
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

  # Translate a path
  def translate_path(path, locale)
    path = path.dup

    # Remove "(.:format)" in routes or "?args" if used elsewhere
    final_options = path.slice!(/(\(.+\)|\?.*)$/)

    segments = path.split('/').map do |segment|
      translate_segment(segment, locale)
    end
    "#{segments.join('/')}#{final_options}"
  end

  # Translate part of a path
  def translate_segment(segment, locale)
    if segment =~ /^[a-z_0-9]+$/i
      translation = I18n.t "routes.#{segment}", default: segment, locale: locale
      CGI.escape(translation)
    else
      segment
    end
  end


  private

  def route_args_for_locale(locale, app, conditions, requirements, defaults, as, anchor, route_set)
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

    [app, locale_conditions, requirements, locale_defaults, locale_as, anchor]
  end
end
