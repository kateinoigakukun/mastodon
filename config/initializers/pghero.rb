# frozen_string_literal: true

return if ENV["RAILS_WEB"]
PgHero.show_migrations = Rails.env.development?
