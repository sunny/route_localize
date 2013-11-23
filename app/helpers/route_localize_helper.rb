# Helper to include in ApplicationHelper

module RouteLocalizeHelper
  # URL to another language to switch to.
  # Can be overridden per-controller.
  def locale_switch_url(locale)
    name = request_route_name.to_s.sub(/_#{I18n.locale}$/, '')
    method = "#{name}_#{locale}_url"
    method = "#{name}_url" unless respond_to?(method)
    method = "root_url" unless respond_to?(method)

    options = { subdomain: locale }
    options.merge! route_localize_options(locale).to_h
    route = send(method, options)

    # Ensure the locale switcher only goes to GET routes
    begin
      Rails.application.routes.recognize_path(route, method: :get)
    rescue ActionController::RoutingError
      route = root_url
    end

    route
  end

  private

  def request_route_name
    Rails.application.routes.router.recognize(request) do |route, _|
      return route.name
    end
  end

  # Allow the app to add parameters to links by definining a
  # `route_localize_path_options` method that accepts a locale.
  def route_localize_options(locale)
    if respond_to?(:route_localize_path_options)
      route_localize_path_options(locale)

    # DEPRECATED method that could redefine the id parameter
    elsif respond_to?(:localize_param)
      { id: localize_param(locale) }

    else
      {}
    end
  end
end
