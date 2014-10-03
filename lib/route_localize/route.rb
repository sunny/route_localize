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
        locale_requirements,
        locale_defaults,
        locale_as,
        anchor]
    end


    private

    # Returns route conditions that match the locale
    def locale_conditions
      cond = conditions.dup

      cond[:path_info] = RouteLocalize.translate_path(
                           conditions[:path_info],
                           locale,
                           by_subdomain: by_subdomain?)

      if by_subdomain?
        cond[:subdomain] = locale.to_s
      else
        cond[:locale] = locale.to_s
      end

      # For good measure
      cond[:required_defaults] -= [:localize, :localize_subdomain]

      cond
    end

    def locale_requirements
      if by_subdomain?
        { subdomain: locale.to_s }
      else
        { locale: locale.to_s }
      end
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

    # Returns true if the route must be by subdomain ("fr.example.com"),
    # false if it should be by path ("example.com/fr")
    def by_subdomain?
      conditions[:required_defaults].include?(:localize_subdomain)
    end

  end
end
