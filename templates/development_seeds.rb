if Rails.env.development?
  namespace :dev do
    desc 'Seed data for development environment'
    task prime: 'db:setup' do
      require 'factory_girl'
      include FactoryGirl::Syntax::Methods

      # create(:user, email: 'user@example.com', password: 'password')
    end
  end
end
