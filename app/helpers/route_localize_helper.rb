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

    # Allow the app to redefine the id parameter with a custom
    # `localize_param` method
    if params[:id] and respond_to?(:localize_param)
      options[:id] = localize_param(locale)
    end

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
end
