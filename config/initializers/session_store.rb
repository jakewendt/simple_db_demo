# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_simple_db_demo_session',
  :secret      => '0b24b9172c1131599a92e91c64b266c41783505e560e8cba9f368e2e52a48a58856c2da5b8611d8a17fa99cc7900c5e5e2fb96b438d22182e72da56dcd9576c8'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
