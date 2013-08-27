module ActionDispatch
  module Routing
    class RouteSet
      def add_route_with_locale(app, conditions = {}, requirements = {}, defaults = {}, as = nil, anchor = true)
        RouteLocalize.translate_route(app, conditions, requirements, defaults, as, anchor, self) do |*args|
          # puts "#{$route} #{args.inspect}"
          add_route_without_locale *args
        end
      end
      alias_method_chain :add_route, :locale
    end
  end
end
