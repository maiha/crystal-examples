class Data::Bundled
  MAKEFILE       = {{ system("cat bundled/Makefile").stringify }}
  DOT_ENV        = {{ system("cat bundled/.env").stringify }}
  CONFIG_TOML    = {{ system("cat bundled/config.toml").stringify }}
  DOCKER_COMPOSE = {{ system("cat bundled/docker-compose.yml").stringify }}
  HEURISTIC_JNL  = {{ system("cat bundled/heuristic.jnl").stringify }}
end
