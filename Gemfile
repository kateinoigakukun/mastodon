# frozen_string_literal: true

source 'https://rubygems.org'
ruby '>= 3.0.0'

gem 'puma', '~> 6.3'
gem 'rails', '~> 7.1.1', group: [:default, :web]
gem 'propshaft', group: [:default, :web]
gem 'thor', '~> 1.2'
gem 'rack', '~> 2.2.7'
gem 'rails-html-sanitizer', '~> 1.6'

# For why irb is in the Gemfile, see: https://ruby.social/@st0012/111444685161478182
gem 'irb', '~> 1.13.1'

gem 'haml-rails', '~>2.0', group: [:default, :web]
gem 'pg', '~> 1.5'
gem 'pghero'
gem 'dotenv-rails', '~> 2.8', group: [:default, :web]

gem 'aws-sdk-s3', '~> 1.123', require: false
gem 'fog-core', '<= 2.4.0'
gem 'fog-openstack', '~> 1.0', require: false
gem 'kt-paperclip', '~> 7.2', group: [:default, :web]
gem 'md-paperclip-azure', '~> 2.2', require: false
gem 'blurhash', '~> 0.1'

gem 'active_model_serializers', '~> 0.10', group: [:default, :web]
gem 'addressable', '~> 2.8', group: [:default, :web]
gem 'bootsnap', '~> 1.18.0', require: false
gem 'browser'
# gem 'charlock_holmes', '~> 0.7.7'
gem 'chewy', '~> 7.3'
gem 'devise', '~> 4.9', group: [:default, :web]
gem 'devise-two-factor', '~> 4.1', group: [:default, :web]

group :pam_authentication, optional: true do
  gem 'devise_pam_authenticatable2', '~> 9.2'
end

gem 'net-ldap', '~> 0.18'

gem 'omniauth-cas', '~> 3.0.0.beta.1'
gem 'omniauth-saml', '~> 2.0'
gem 'omniauth_openid_connect', '~> 0.6.1'
gem 'omniauth', '~> 2.0', group: [:default, :web]
gem 'omniauth-rails_csrf_protection', '~> 1.0'

gem 'color_diff', '~> 0.1'
gem 'csv', '~> 3.2'
gem 'discard', '~> 1.2', group: [:default, :web]
gem 'doorkeeper', '~> 5.6', group: [:default, :web]
gem 'ed25519', '~> 1.3'
gem 'fast_blank', '~> 1.0'
gem 'fastimage'
gem 'hiredis', '~> 0.6'
gem 'redis-namespace', '~> 1.10'
gem 'htmlentities', '~> 4.3'
gem 'http', '~> 5.1'
gem 'http_accept_language', '~> 2.1'
gem 'httplog', '~> 1.6.2', group: [:default, :web]
gem 'i18n', '1.14.1' # TODO: Remove version when resolved: https://github.com/glebm/i18n-tasks/issues/552 / https://github.com/ruby-i18n/i18n/pull/688
gem 'idn-ruby', require: 'idn', group: [:default, :web]
gem 'inline_svg', group: [:default, :web]
gem 'kaminari', '~> 1.2', group: [:default, :web]
gem 'link_header', '~> 0.0'
gem 'mime-types', '~> 3.5.0', require: 'mime/types/columnar', group: [:default, :web]
gem 'nokogiri', github: 'kateinoigakukun/nokogiri', ref: '8e9904e5a891af43ad0c1e8eec467ecbbf55d55f', group: [:default, :web] 
gem 'nio4r', github: 'kateinoigakukun/nio4r', ref: 'd219d9bce40435bd993b6ed6e425ae7e76b62d04'
gem 'nsa'
gem 'oj', github: 'kateinoigakukun/oj', ref: 'dce0244a0ca260334b0b9dec50ac674132ccc85e', group: [:default, :web]
gem 'ox', '~> 2.14'
gem 'parslet'
gem 'public_suffix', '~> 5.0'
gem 'pundit', '~> 2.3', group: [:default, :web]
gem 'premailer-rails'
gem 'rack-attack', '~> 6.6', group: [:default, :web]
gem 'rack-cors', '~> 2.0', require: 'rack/cors', group: [:default, :web]
gem 'rails-i18n', '~> 7.0'
gem 'redcarpet', '~> 3.6'
install_if -> { ENV["RAILS_WEB"].nil? } do
  gem 'redis', '~> 4.5', require: ['redis', 'redis/connection/hiredis']
  gem 'mario-redis-lock', '~> 1.2', require: 'redis_lock'
end
gem 'rqrcode', '~> 2.2'
gem 'ruby-progressbar', '~> 1.13'
gem 'sanitize', '~> 6.0', group: [:default, :web]
gem 'scenic', '~> 1.7'
gem 'sidekiq', '~> 6.5'
gem 'sidekiq-scheduler', '~> 5.0'
gem 'sidekiq-unique-jobs', '~> 7.1'
gem 'sidekiq-bulk', '~> 0.2.0'
gem 'simple-navigation', '~> 4.4', group: [:default, :web]
gem 'simple_form', '~> 5.2', group: [:default, :web]
gem 'stoplight', '~> 4.1'
gem 'strong_migrations', '1.8.0', group: [:default, :web]
gem 'tty-prompt', '~> 0.23', require: false
gem 'twitter-text', '~> 3.1.0', group: [:default, :web]
gem 'tzinfo-data', '~> 1.2023', group: [:default, :web]
gem 'webpacker', '~> 5.4', group: [:default, :web]
gem 'webpush', github: 'ClearlyClaire/webpush', ref: 'f14a4d52e201128b1b00245d11b6de80d6cfdcd9', group: [:default, :web]
gem 'webauthn', '~> 3.0'

gem 'json-ld', group: [:default, :web]
gem 'json-ld-preloaded', '~> 3.2', group: [:default, :web]
gem 'rdf-normalize', '~> 0.5'

gem 'private_address_check', '~> 0.5'

group :test do
  # Adds RSpec Error/Warning annotations to GitHub PRs on the Files tab
  gem 'rspec-github', '~> 2.4', require: false

  # RSpec progress bar formatter
  gem 'fuubar', '~> 2.5'

  # RSpec helpers for email specs
  gem 'email_spec'

  # Extra RSpec extension methods and helpers for sidekiq
  gem 'rspec-sidekiq', '~> 4.0'

  # Browser integration testing
  gem 'capybara', '~> 3.39'
  gem 'selenium-webdriver'

  # Used to reset the database between system tests
  gem 'database_cleaner-active_record'

  # Used to mock environment variables
  gem 'climate_control'

  # Add back helpers functions removed in Rails 5.1
  gem 'rails-controller-testing', '~> 1.0'

  # Validate schemas in specs
  gem 'json-schema', '~> 4.0'

  # Test harness fo rack components
  gem 'rack-test', '~> 2.1'

  # Coverage formatter for RSpec test if DISABLE_SIMPLECOV is false
  gem 'simplecov', '~> 0.22', require: false
  gem 'simplecov-lcov', '~> 0.8', require: false

  # Stub web requests for specs
  gem 'webmock', '~> 3.18'
end

group :development do
  # Code linting CLI and plugins
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false

  # Annotates modules with schema
  gem 'annotate', '~> 3.2'

  # Enhanced error message pages for development
  gem 'better_errors', '~> 2.9'
  gem 'binding_of_caller', '~> 1.0'

  # Preview mail in the browser
  gem 'letter_opener', '~> 1.8'
  gem 'letter_opener_web', '~> 2.0'

  # Security analysis CLI tools
  gem 'brakeman', '~> 6.0', require: false
  gem 'bundler-audit', '~> 0.9', require: false

  # Linter CLI for HAML files
  gem 'haml_lint', require: false

  # Validate missing i18n keys
  gem 'i18n-tasks', '~> 1.0', require: false
end

# Generate fake data values
gem 'faker', '~> 3.2', group: [:development, :test, :web]

group :development, :test do
  # Interactive Debugging tools
  gem 'debug', '~> 1.8'


  # Generate factory objects
  gem 'fabrication', '~> 2.30'

  # Profiling tools
  gem 'memory_profiler', require: false
  gem 'ruby-prof', require: false
  gem 'stackprof', require: false
  gem 'test-prof'

  # RSpec runner for rails
  gem 'rspec-rails', '~> 6.0'

  unless RUBY_PLATFORM =~ /wasm/
    gem 'ruby_wasm', git: 'https://github.com/ruby/ruby.wasm', ref: "576cc3f6d838b0f942e045dd88fb295347d2291c"
  end
end

group :production do
  gem 'lograge', '~> 0.12', group: [:default, :web]
end

gem 'concurrent-ruby', require: false
gem 'connection_pool', require: false, group: [:default, :web]
gem 'xorcist', '~> 1.1'
gem 'cocoon', '~> 1.2'

gem 'net-http', '~> 0.4.0'
gem 'rubyzip', '~> 2.3'

gem 'hcaptcha', '~> 7.1'

gem 'mail', '~> 2.8'

gem 'io-console'
gem 'stringio', '3.1.1'

gem 'activerecord-nulldb-adapter', group: [:web]
gem 'js', git: 'https://github.com/ruby/ruby.wasm',
  ref: "0ca30636702eb7e1bb2a17b3868a458a03f045a8", # branch: katei/kaigi-staging
  glob: 'packages/gems/js/*.gemspec', group: [:web]
