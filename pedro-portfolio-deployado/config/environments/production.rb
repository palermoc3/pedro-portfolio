require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

config.public_file_server.enabled = true

config.public_file_server.headers = {
  "cache-control" => "public, max-age=#{1.year.to_i}"
}

  # Assets
  config.assets.compile = false
  config.assets.digest = true

  # SSL (ok no Fly)
  config.force_ssl = true

  # Logging
  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false

  # I18n
  config.i18n.fallbacks = true

  # ActiveRecord — NÃO FORÇAR CONEXÃO NO BOOT
  config.active_record.dump_schema_after_migration = false
end
