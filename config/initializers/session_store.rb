
if Rails.env == "production"
    Rails.application.config.session_store :cookie_store, key: "_traskipl_auth", domain: ENV['DOMAIN']
else 
    Rails.application.config.session_store :cookie_store, key: "_traskipl_auth"
end