# Helper to include in ApplicationHelper

module RouteLocalizeHelper

  # Returns the URL to the current page in another locale
  def locale_switch_url(locale)
    route_localize_switch(locale)
  end

  # Returns the URL to the current page in another locale, using subdomains
  def locale_switch_subdomain_url(locale)
    route_localize_switch(locale, subdomain: locale)
  end


  private

  def route_localize_switch(locale, options = {})
    name = route_localize_route_name
    method = "#{name}_#{locale}_url"
    method = "#{name}_url" unless respond_to?(method)
    method = "#{locale}_root_url" unless respond_to?(method)
    method = "root_url" unless respond_to?(method)

    options.merge! route_localize_options(locale)
    route = send(method, options)

    # Ensure the locale switcher only goes to GET routes
    begin
      Rails.application.routes.recognize_path(route, method: :get)
    rescue ActionController::RoutingError
      route = root_url(options)
    end

    route
  end

  # Return current route name without the _en or _fr
  def route_localize_route_name
    Rails.application.routes.router.recognize(request) do |route, *_|
      return route.name.to_s.sub(/_#{I18n.locale}$/, '')
    end
  end

  # Allow the app to add parameters to links by definining a
  # `route_localize_path_options` method that accepts a locale.
  def route_localize_options(locale)
    if respond_to?(:route_localize_path_options)
      route_localize_path_options(locale).to_h
    else
      {}
    end
  end
end
