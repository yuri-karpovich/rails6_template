=begin
Template Name: Rails 6 template
Author: Yury Karpovich
Author URI: https://github.com/yuri-karpovich
Instructions: $ rails new app_name -d mysql --webpack=stimulus -m https://github.com/yuri-karpovich/rails6_template/template.rb
=end

GEMS_LOCATION = '.bundle/gems'.freeze

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def configure_template
  # TODO configure wizard
  # @clickhouse = true
  # @redis = true
end

def make_symlink_vendor
  @create_symlinks = yes?("Create symlinks for #{GEMS_LOCATION} -> ../bundle and node_modules -> ../node_modules?
Don't use if you are not sure! node_modules folder will be removed!!!
Yes or No (default: No):")
  puts "Your answer: #{@create_symlinks ? 'yes' : 'no' }"
  return unless @create_symlinks

  create_bundle_config GEMS_LOCATION
  run "mkdir -p ../bundle"
  File.symlink '../../bundle', GEMS_LOCATION

  remove_dir 'node_modules'
  run 'mkdir -p ../node_modules'
  File.symlink '../node_modules', 'node_modules'
  run 'yarn install'
end

def create_bundle_config(bundle_path = GEMS_LOCATION)
  run 'mkdir -p .bundle'
  bundler_config = {}
  bundler_config['BUNDLE_DISABLE_SHARED_GEMS'] = 'true'
  bundler_config['BUNDLE_PATH'] = bundle_path
  File.open('.bundle/config', 'w') {|f| f.write bundler_config.to_yaml }
end

def remove_comment_of_gems
  gsub_file('Gemfile', /^\s*#.*$\n/, '')
end

def remove_gem(*names)
  names.each do |name|
    gsub_file 'Gemfile', /gem '#{name}'.*\n/, ''
  end
end

def add_gems
  gem 'dotenv-rails'
  gem 'simple_form'
  gem 'friendly_id'
  gem 'sidekiq'
  gem 'friendly_id'

  gem_group :development do
    gem 'pry'
    gem 'pry-nav'
    gem 'better_errors'
    gem 'binding_of_caller'
  end
end


def stop_spring
  run 'spring stop'
end

def configure_gems
  configure_simpleform
  configure_friendly_id
  configure_sidekiq
end


def configure_docker
  directory 'config/docker', force: true

  copy_file 'Dockerfile'
  gsub_file('Dockerfile', 'FROM ruby:2.5.1', "FROM ruby:#{RUBY_VERSION}")

  copy_file '.env'
  gsub_file('.env', 'PROJECT_NAME=PROJECT_NAME', "PROJECT_NAME=#{app_name}")

  copy_file 'config/database.yml'

  copy_file '.dockerignore'

  # TODO make Clickhouse optional
  copy_file 'docker-compose-development.yml'
  copy_file 'docker-compose-production.yml'
  copy_file 'entrypoint.sh'

  copy_file 'start_docker.sh'
  run 'chmod +x start_docker.sh'
  copy_file 'stop_docker.sh'
  run 'chmod +x stop_docker.sh'
end

def configure_simpleform
  stop_spring
  generate 'simple_form:install', '--bootstrap'
end

def configure_friendly_id
  stop_spring
  generate 'friendly_id'
end

#
def configure_sidekiq
  environment 'config.active_job.queue_adapter = :sidekiq'

  insert_into_file 'config/routes.rb',
                   "require 'sidekiq/web'\n\n",
                   before: 'Rails.application.routes.draw do'

  content = <<-RUBY
    mount Sidekiq::Web => '/sidekiq'
  RUBY
  insert_into_file 'config/routes.rb', "#{content}\n\n", after: "Rails.application.routes.draw do\n"
end

def add_procfile
  copy_file 'Procfile'
end

def add_rubocop
  copy_file '.rubocop.yml'
end

def add_readme
  insert_into_file 'README.md',
  <<TEXT

## Deploy
### Preconditions

1. Set variables in .env file
1. Make sure that user has write permissions to DATA_DIR (default: `/opt/apps_data`)
1. `docker` and `docker-compose` should be installed on server

### How to deploy
To start docker containers:

    ./start_docker.sh docker-compose-production.yml

To stop containers:

    ./stop_docker.sh docker-compose-production.yml

## Development
### Setup dev environment
To start docker containers:

    ./start_docker.sh docker-compose-development.yml
TEXT

end

# Main setup
source_paths
make_symlink_vendor
remove_comment_of_gems
remove_gem('sqlite3')
add_gems
add_procfile
add_rubocop
configure_docker
add_readme

after_bundle do
  configure_gems
  say "#{app_name} successfully configured! 👍", :green
end