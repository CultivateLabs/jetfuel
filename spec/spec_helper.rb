require 'capybara/rspec'
require 'bundler/setup'

Bundler.require(:default, :test)

require (Pathname.new(__FILE__).dirname + '../lib/jetfuel').expand_path

Dir['./spec/support/**/*.rb'].each { |file| require file }

RSpec.configure do |config|
  config.include JetfuelTestHelpers

  config.before(:all) do
    create_tmp_directory
  end

  config.before(:each) do
    drop_dummy_database
    remove_project_directory

    FakeHeroku.clear!
    FakeGithub.clear!
  end
end
