class Data::Bundled
  MAKEFILE       = {{ system("cat bundled/Makefile").stringify }}
  DOT_ENV        = {{ system("cat bundled/.env").stringify }}
  CONFIG_TOML    = {{ system("cat bundled/config.toml").stringify }}
  COMPOSE        = {{ system("cat bundled/compose.yaml").stringify }}
  HEURISTIC_JNL  = {{ system("cat bundled/heuristic.jnl").stringify }}
  HELPER_CR      = {{ system("cat bundled/helper.cr").stringify }}
end
