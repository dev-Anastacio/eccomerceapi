Rails.application.config.session_store :cookie_store,
  key: "_meu_projeto_session",
  same_site: :lax,
  secure: Rails.env.production?
