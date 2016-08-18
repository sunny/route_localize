Changelog
=========

## v1.1.0

- Remove Rails version compatibility for versions other than `4.0`

## v1.0.0

Major breaking changes:

- Renamed `localize` route scope to `localize_subdomain`
- Renamed `locale_switch_url` helper to `locale_switch_subdomain_url`
- Localize by path `/:locale/` by using the `localize` route scope
- Remove deprecated `localize_param` helper to that helped redefine
  the `id` parameter

## v0.0.7

- First public version
