ActionDispatch::Reloader.to_prepare do
  # Reloading to mimick loading routes before locales,
  # like activeadmin does.
  Rails.application.reload_routes!
end
