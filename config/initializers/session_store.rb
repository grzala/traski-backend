
if Rails.env == "production"
    # CHANGE IN PROD
    Rails.application.config.session_store :cookie_store, key: "_authentication_app", domain: "mydomain"
else 
    Rails.application.config.session_store :cookie_store, key: "_authentication_app"
end