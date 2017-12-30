source 'https://rubygems.org'

git_source(:github) do |repo_name|
	repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
	"https://github.com/#{repo_name}.git"
end


gem 'rails', '~> 5.1.4'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'redis', '~> 3.0'

group :development, :test do
	gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
	gem 'capybara', '~> 2.13'
	gem 'selenium-webdriver'
end

group :development do
	gem 'web-console', '>= 3.3.0'
	gem 'listen', '>= 3.0.5', '< 3.2'
	gem 'spring'
	gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'devise'
gem 'bootstrap', '~> 4.0.0.beta2.1'
gem 'jquery-rails'
gem 'perfect-scrollbar-rails'
gem 'rolify'
gem 'paranoia', '~> 2.3.1'
gem 'vmstat', '~> 2.3.0'
gem 'sys-filesystem', '~> 1.1.6'
gem 'ransack'
gem 'simple_form'
gem 'kaminari'
gem 'bootstrap4-kaminari-views'
gem 'mousetrap-rails'
gem 'codemirror-rails'
gem 'net-ssh'

gem 'stripe', '~> 3.8'
gem 'jquery-turbolinks'

gem 'stripe_event', '~> 1.5'

gem 'receipts'

