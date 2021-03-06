module Jetfuel
  class AppBuilder < Rails::AppBuilder
    include Jetfuel::Actions

    def readme
      template 'README.md.erb', 'README.md'
    end

    def raise_on_delivery_errors
      replace_in_file 'config/environments/development.rb',
        'raise_delivery_errors = false', 'raise_delivery_errors = true'
    end

    def raise_on_unpermitted_parameters
      action_on_unpermitted_parameters = <<-RUBY

  # Raise an ActionController::UnpermittedParameters exception when
  # a parameter is not explcitly permitted but is passed anyway.
  config.action_controller.action_on_unpermitted_parameters = :raise
      RUBY
      inject_into_file(
        "config/environments/development.rb",
        action_on_unpermitted_parameters,
        before: "\nend"
      )
    end

    def provide_setup_script
      copy_file 'bin_setup', 'bin/setup'
      run 'chmod a+x bin/setup'
    end

    def configure_generators
      config = <<-RUBY
    config.generators do |generate|
      generate.helper false
      generate.javascript_engine false
      generate.request_specs false
      generate.routing_specs false
      generate.stylesheets false
      generate.test_framework :rspec
      generate.view_specs false
    end

      RUBY

      inject_into_class 'config/application.rb', 'Application', config
    end

    def set_up_factory_girl_for_rspec
      copy_file 'factory_girl_rspec.rb', 'spec/support/factory_girl.rb'
    end

    def setup_guard
      copy_file 'Guardfile', 'Guardfile'
    end

    def configure_poltergeist
      copy_file 'poltergeist.rb', 'spec/support/poltergeist.rb'
    end

    def configure_newrelic
      template 'newrelic.yml.erb', 'config/newrelic.yml'
    end

    def configure_smtp
      copy_file 'smtp.rb', 'config/smtp.rb'

      prepend_file 'config/environments/production.rb',
        "require Rails.root.join('config/smtp')\n"

      config = <<-RUBY

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = SMTP_SETTINGS
      RUBY

      inject_into_file 'config/environments/production.rb', config,
        :after => 'config.action_mailer.raise_delivery_errors = false'
    end

    def enable_rack_deflater
      config = <<-RUBY

  # Enable deflate / gzip compression of controller-generated responses
  config.middleware.use Rack::Deflater
      RUBY

      inject_into_file(
        'config/environments/production.rb', 
        config,
        after: serve_static_files_line
      )
    end

    def setup_asset_host
      # replace_in_file 'config/environments/production.rb',
      #   '# config.action_controller.asset_host = "http://assets.example.com"',
      #   "config.action_controller.asset_host = ENV.fetch('ASSET_HOST')"

      # replace_in_file 'config/environments/production.rb',
      #   "config.assets.version = '1.0'",
      #   "config.assets.version = ENV.fetch('ASSETS_VERSION')"

      inject_into_file(
        'config/environments/production.rb',
        'config.static_cache_control = "public, max-age=#{1.year.to_i}"',
        after: serve_static_files_line
      )
    end

    def setup_staging_environment
      staging_file = 'config/environments/staging.rb'
      copy_file 'staging.rb', staging_file

      config = <<-RUBY

Rails.application.configure do
  # ...
end
      RUBY

      append_file staging_file, config
    end

    def setup_secret_token
      template 'secrets.yml', 'config/secrets.yml', force: true
    end

    def create_partials_directory
      empty_directory 'app/views/application'
    end

    def create_shared_flashes
      copy_file '_flashes.html.erb', 'app/views/application/_flashes.html.erb'
    end

    def create_shared_javascripts
      copy_file '_javascript.html.erb', 'app/views/application/_javascript.html.erb'
    end

    def create_application_layout
      template 'suspenders_layout.html.erb.erb',
        'app/views/layouts/application.html.erb',
        force: true
    end

    def remove_turbolinks
      replace_in_file 'app/assets/javascripts/application.js',
        /\/\/= require turbolinks\n/,
        ''
    end

    def add_bootstrap_js
      inject_into_file 'app/assets/javascripts/application.js', "//= require bootstrap-sprockets\n//= require leather\n",
        after: /\/\/= require jquery_ujs\n/
    end

    def use_postgres_config_template
      template 'postgresql_database.yml.erb', 'config/database.yml',
        force: true
    end

    def create_database
      bundle_command 'exec rake db:create db:migrate'
    end

    def replace_gemfile
      remove_file 'Gemfile'
      template 'Gemfile.erb', 'Gemfile'
    end

    def set_ruby_to_version_being_used
      create_file '.ruby-version', "#{Jetfuel::RUBY_VERSION}\n"
    end

    def setup_heroku_specific_gems
      inject_into_file 'Gemfile', "\n\s\sgem 'rails_12factor'",
        after: /group :staging, :production do/
    end

    def setup_capistrano_specific_gems
      inject_into_file 'Gemfile', "\n\s\sgem 'capistrano',  '~> 3.2'\n\s\sgem 'capistrano-rails', '~> 1.1'\n\s\sgem 'capistrano-sidekiq'",
        after: /gem 'spring-commands-rspec'/
    end

    def enable_database_cleaner
      copy_file 'database_cleaner_rspec.rb', 'spec/support/database_cleaner.rb'
    end

    def configure_spec_support_features
      empty_directory_with_keep_file 'spec/features'
      empty_directory_with_keep_file 'spec/support/features'
    end

    def configure_rspec
      remove_file 'spec/spec_helper.rb'
      copy_file 'spec_helper.rb', 'spec/spec_helper.rb'
      remove_file '.rspec'
      copy_file '.rspec', '.rspec'
    end

    def configure_travis
      template 'travis.yml.erb', '.travis.yml'
    end

    def configure_i18n_in_specs
      copy_file 'i18n.rb', 'spec/support/i18n.rb'
    end

    def configure_background_jobs
      run 'mkdir app/workers'
      copy_file 'background_jobs_rspec.rb', 'spec/support/background_jobs.rb'
      # run 'bundle exec rails g delayed_job:active_record'
    end

    def configure_action_mailer_in_specs
      copy_file 'action_mailer.rb', 'spec/support/action_mailer.rb'
    end

    def configure_time_zone
      config = <<-RUBY
    config.active_record.default_timezone = :utc

      RUBY
      inject_into_class 'config/application.rb', 'Application', config
    end

    def configure_time_formats
      remove_file 'config/locales/en.yml'
      copy_file 'config_locales_en.yml', 'config/locales/en.yml'
    end

    def configure_rack_timeout
      rack_timeout_config = <<-RUBY
Rack::Timeout.timeout = (ENV["RACK_TIMEOUT"] || 10).to_i
      RUBY

      append_file "config/environments/production.rb", rack_timeout_config
    end

    def configure_action_mailer
      action_mailer_host 'development', "#{app_name}.local"
      action_mailer_host 'test', 'www.example.com'
      action_mailer_host 'staging', "staging.#{app_name}.com"
      action_mailer_host 'production', "#{app_name}.com"
    end

    def fix_i18n_deprecation_warning
      config = <<-RUBY
    config.i18n.enforce_available_locales = true

      RUBY
      inject_into_class 'config/application.rb', 'Application', config
    end

    def generate_rspec
      run 'bundle exec rails g rspec:install'
    end

    def configure_unicorn
      copy_file 'unicorn.rb', 'config/unicorn.rb'
    end

    def setup_foreman
      copy_file 'sample.env', 'sample.env'
      copy_file 'sample.env', '.env'
      replace_in_file ".env", /development_secret/, generate_secret
      copy_file 'Procfile', 'Procfile'
    end

    def setup_stylesheets
      remove_file 'app/assets/stylesheets/application.css'
      copy_file 'application.css.scss',
        'app/assets/stylesheets/application.css.scss'
      copy_file '_flashes.css.scss',
        'app/assets/stylesheets/_flashes.css.scss'
    end
    
    def install_leather
      run "bundle exec rails g leather:install"
    end

    def install_simple_form
      run "bundle exec rails g simple_form:install --bootstrap"
    end

    def setup_helpers
      remove_file 'app/helpers/application_helper.rb'
      copy_file 'application_helper.rb',
        'app/helpers/application_helper.rb'
    end

    def install_devise
      run 'bundle exec rails g devise:install'
      remove_file 'config/initializers/devise.rb'
      copy_file 'devise.rb',
        'config/initializers/devise.rb'
    end

    def create_devise_user
      run 'bundle exec rails g devise User'
      run 'rake db:migrate'
    end

    def gitignore_files
      remove_file '.gitignore'
      copy_file 'suspenders_gitignore', '.gitignore'
      [
        'app/views/pages',
        'spec/lib',
        'spec/controllers',
        'spec/helpers',
        'spec/support/matchers',
        'spec/support/mixins',
        'spec/support/shared_examples'
      ].each do |dir|
        run "mkdir #{dir}"
        run "touch #{dir}/.keep"
      end
    end

    def init_git
      run 'git init'
    end

    def create_heroku_apps
      path_addition = override_path_for_tests
      heroku_account = ask("If you are using the heroku-accounts gem, what account would you like to use? (leave blank if n/a)")
      unless heroku_account.blank?
        run "#{path_addition} heroku accounts:set #{heroku_account}"
      end
      run "#{path_addition} heroku create #{app_name}-production --remote=production"
      run "#{path_addition} heroku create #{app_name}-staging --remote=staging"
      run "#{path_addition} heroku config:set RACK_ENV=staging RAILS_ENV=staging --remote=staging"
      email_recipient = ask("What email address do you want emails to be delivered to on staging?")
      run "#{path_addition} heroku config:set EMAIL_RECIPIENTS=#{email_recipient} --remote=staging"
    end

    def set_heroku_remotes
      remotes = <<-SHELL

# Set up staging and production git remotes.
git remote add staging git@heroku.com:#{app_name}-staging.git || true
git remote add production git@heroku.com:#{app_name}-production.git || true

# Join the staging and production apps.
#{join_heroku_app('staging')}
#{join_heroku_app('production')}
      SHELL

      append_file 'bin/setup', remotes
    end

    def join_heroku_app(environment)
      heroku_app_name = "#{app_name}-#{environment}"
      <<-SHELL
if heroku join --app #{heroku_app_name} &> /dev/null; then
  echo 'You are a collaborator on the "#{heroku_app_name}" Heroku app'
else
  echo 'Ask for access to the "#{heroku_app_name}" Heroku app'
fi
      SHELL
    end

    def set_heroku_rails_secrets
      path_addition = override_path_for_tests
      run "#{path_addition} heroku config:set SECRET_KEY_BASE=#{generate_secret} --remote=staging"
      run "#{path_addition} heroku config:set SECRET_KEY_BASE=#{generate_secret} --remote=production"
    end

    def copy_capistrano_configuration_files
      run "mkdir -p config/deploy"
      template 'Capfile', 'Capfile'
      template 'cap_deploy.erb', 'config/deploy.rb'
      template 'cap_staging.erb', 'config/deploy/staging.rb'
      template 'cap_production.erb', 'config/deploy/production.rb'
      run "mkdir -p lib/capistrano/tasks"

      replace_in_file 'config/deploy.rb', /GITHUB_REPO/, ask("What is your github repository address?")
      replace_in_file 'config/deploy/production.rb', /IP_ADDRESS/, ask("What is your app's IP address?")
    end

    def create_github_repo(repo_name)
      path_addition = override_path_for_tests
      run "#{path_addition} hub create #{repo_name}"
    end

    def setup_segment_io
      copy_file '_analytics.html.erb',
        'app/views/application/_analytics.html.erb'
    end

    def copy_miscellaneous_files
      copy_file 'errors.rb', 'config/initializers/errors.rb'
    end

    def customize_error_pages
      meta_tags =<<-EOS
  <meta charset='utf-8' />
  <meta name='ROBOTS' content='NOODP' />
  <meta name='viewport' content='initial-scale=1' />
      EOS

      %w(500 404 422).each do |page|
        inject_into_file "public/#{page}.html", meta_tags, :after => "<head>\n"
        replace_in_file "public/#{page}.html", /<!--.+-->\n/, ''
      end
    end

    def remove_routes_comment_lines
      replace_in_file 'config/routes.rb',
        /Rails\.application\.routes\.draw do.*end/m,
        "Rails.application.routes.draw do\nend"
    end

    def add_sidekiq_web_routes
      replace_in_file 'config/routes.rb',
        /Rails\.application\.routes\.draw/,
        "require 'sidekiq/web'\n\nRails.application.routes.draw"

      replace_in_file 'config/routes.rb',
      /\nend/,
      "\n\s\smount Sidekiq::Web, at: '/sidekiq'\nend"
    end

    def disable_xml_params
      copy_file 'disable_xml_params.rb', 'config/initializers/disable_xml_params.rb'
    end

    def setup_default_rake_task
      append_file 'Rakefile' do
        "task(:default).clear\ntask :default => [:spec]\n"
      end
    end

    private

    def override_path_for_tests
      if ENV['TESTING']
        support_bin = File.expand_path(File.join('..', '..', 'spec', 'fakes', 'bin'))
        "PATH=#{support_bin}:$PATH"
      end
    end

    def factories_spec_rake_task
      IO.read find_in_source_paths('factories_spec_rake_task.rb')
    end

    def generate_secret
      SecureRandom.hex(64)
    end

    def serve_static_files_line
      "config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?\n"
    end
  end
end
