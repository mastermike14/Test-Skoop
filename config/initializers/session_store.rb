# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_skloop_session',
  :secret      => 'c85fcb5121b29e9cf6d5fbece78f44bcf13c13fd64263ad2d07d90075d6621cb4525b31f3a7ab23cde1acc4d440197ab4a7605be302f8c53b80c5fc0c9b64f82'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
