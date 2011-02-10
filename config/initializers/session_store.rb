# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_feedagg_session',
  :secret      => '047051124dc608e54fe6737293a25dcd7d8cc2e987100cbb8af67bedb7c1a2e293f18ae499dc05048b6b0b610ae9fe42679b3f5ac074609ef3306cba4fddfa9d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
