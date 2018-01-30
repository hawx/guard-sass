require 'guard/plugin'
require 'guard/compat/test/helper'
require 'guard/sass'

# Guard::Watcher::Pattern::Matcher has no `==` method
# See https://github.com/guard/guard/pull/889
module Guard
  class Watcher
    def ==(other)
      action == other.action && pattern == other.pattern
    end

    class Pattern
      class Matcher
        attr_reader :matcher

        def ==(other)
          matcher == other.matcher
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.color = true
  config.formatter = :doc
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.full_backtrace = false

  config.before(:each) do
    ENV['GUARD_ENV'] = 'test'
    @fixture_path = Pathname.new(File.expand_path('../fixtures/', __FILE__))
    @lib_path = Pathname.new(File.expand_path('../../lib/', __FILE__))
  end
end
