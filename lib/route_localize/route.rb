module RouteLocalize
  # Represents a route line that needs to be translated in a given locale.
  #
  # Instances of Route accept the same arguments that
  # `ActionDispatch::Routing::RouteSet`'s method `add_route` accepts, with the
  # addition of:
  # - `route_set`: the app's current route set
  # - `locale`: locale for the given route
  Route = Struct.new(:app, :conditions, :requirements, :defaults,
                        :as, :anchor, :route_set, :locale) do

    # Returns the arguments to pass on to `add_route` to create the route
    def to_add_route_arguments
      [app,
        locale_conditions,
        requirements,
        locale_defaults,
        locale_as,
        anchor]
    end


    private

    # Returns route conditions that match the locale
    def locale_conditions
      cond = conditions.dup

      cond[:path_info] = translate_path(cond[:path_info])

      if by_subdomain?
        cond[:subdomain] = locale.to_s
      else
        cond[:locale] = locale.to_s
      end

      # TODO: remove if found to be unnecessary after all
      # cond[:required_defaults] -= [:localize, :localize_url]

      cond
    end

    # Return route defaults for the locale
    def locale_defaults
      if by_subdomain?
        defaults.merge(subdomain: locale.to_s)
      else
        defaults.merge(locale: locale.to_s)
      end
    end

    # Returns a route name that includes the locale
    # Example: "trees" -> "trees_fr"
    def locale_as
      locale_as = "#{as}_#{locale}"
      locale_as = nil if route_set.named_routes.routes[locale_as.to_sym]
      locale_as
    end

    # Returns a translated path
    # Example: "/trees/:id(.:format)" -> "/arbres/:id(.:format)", …
    def translate_path(path)
      path = path.dup

      # Remove "(.:format)" in routes or "?args" if used elsewhere
      final_options = path.slice!(/(\(.+\)|\?.*)$/)

      segments = path.split('/').map do |segment|
        translate_segment(segment)
      end

      segments.unshift(":locale") unless by_subdomain?
      segments = segments.reject(&:blank?)

      "/#{segments.join('/')}#{final_options}"
    end

    # Translates part of a path if it can
    # Example: "trees" -> "arbres", ":id" -> ":id"
    def translate_segment(segment)
      if segment =~ /^[a-z_0-9]+$/i
        translation = I18n.t "routes.#{segment}", default: segment,
                                                  locale: locale
        CGI.escape(translation)
      else
        segment
      end
    end

    # Returns true if the route must be by subdomain ("fr.example.com"),
    # false if it should be by path ("example.com/fr")
    def by_subdomain?
      conditions[:required_defaults].include?(:localize)
    end

  end
end
