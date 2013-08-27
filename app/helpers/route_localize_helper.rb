# Helper to include in ApplicationHelper

module RouteLocalizeHelper
  # URL to another language to switch to.
  # Can be overridden per-controller.
  def locale_switch_url(locale)
    name = request_route_name.to_s.sub(/_#{I18n.locale}$/, '')
    method = "#{name}_#{locale}_url"
    method = "#{name}_url" unless respond_to?(method)
    method = "root_url" unless respond_to?(method)

    if params[:id] and respond_to?(:localize_param)
      send(method, subdomain: locale, id: localize_param(locale))
    else
      send(method, subdomain: locale)
    end
  end

  private

  def request_route_name
    Rails.application.routes.router.recognize(request) do |route, _|
      return route.name
    end
  end
end
