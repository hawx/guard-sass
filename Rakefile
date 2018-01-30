require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task default: :spec

namespace(:spec) do
  desc 'Run tests on all versions of ruby (requires rbenv)'
  task :all do
    `rbenv versions --bare`.split("\n").each do |vers|
      run_for vers, ['bundle install', 'bundle exec rake']
    end
  end
end

def run_for(vers, commands)
  commands = commands.map { |command| "rbenv exec #{command}" }.join(' && ')
  system "RBENV_VERSION='#{vers}' sh -c '#{commands}'"
end
