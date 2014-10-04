module RouteLocalize
  Route = Struct.new(:locale, :app, :conditions, :requirements, :defaults,
                        :as, :anchor, :route_set) do
    # def locales
    #   defaults.delete(:localize) || defaults.delete(:localize_url)
    # end

    def route_args
      [app,
        locale_conditions,
        requirements,
        locale_defaults,
        locale_as,
        anchor]
    end

    def locale_conditions
      cond = conditions.dup
      cond[:path_info] = translate_path(cond[:path_info], locale)
      if cond[:required_defaults].include?(:localize)
        cond[:subdomain] = locale.to_s
      else
        cond[:locale] = locale.to_s
      end
      cond[:required_defaults] = cond[:required_defaults] -= [:localize, :localize_url]
      cond
    end

    def locale_defaults
      if by_subdomain?
        defaults.merge(subdomain: locale.to_s)
      else
        defaults.merge(locale: locale.to_s)
      end
    end

    # Route name
    def locale_as
      locale_as = "#{as}_#{locale}"
      locale_as = nil if route_set.named_routes.routes[locale_as.to_sym]
      locale_as
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

    def by_subdomain?
      conditions[:required_defaults].include?(:localize)
    end

  end
end
