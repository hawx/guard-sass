require 'guard'
require 'guard/guard'
require 'guard/watcher'
require 'sass/plugin'

module Guard
  class Sass < Guard

    autoload :Runner,    'guard/sass/runner'
    autoload :Formatter, 'guard/sass/formatter'

    DEFAULTS = {
      :all_on_start => false,
      :output       => 'css',
      :extension    => '.css',
      :style        => :nested,
      :shallow      => false,
      :line_numbers => false,
      :debug_info   => false,
      :noop         => false,
      :hide_success => false,
      :load_paths   => ::Sass::Plugin.template_location_array.map(&:first)
    }

    # @param watchers [Array<Guard::Watcher>]
    # @param options [Hash]
    # @option options [String] :input
    #   The input directory
    # @option options [String] :output
    #   The output directory
    # @option options [Array<String>] :load_paths
    #   List of directories you can @import from
    # @option options [Boolean] :shallow
    #   Whether to output nested directories
    # @option options [Boolean] :line_numbers
    #   Whether to output human readable line numbers as comments in the file
    # @option options [Boolean] :debug_info
    #   Whether to output file and line number info for FireSass
    # @option options [Boolean] :noop
    #   Whether to run in "asset pipe" mode, no ouput, just validation
    # @option options [Boolean] :hide_success
    #   Whether to hide all success messages
    # @option options [Symbol] :style
    #   See http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#output_style
    def initialize(watchers=[], options={})
      load_paths = options.delete(:load_paths) || []

      if options[:input]
        load_paths << options[:input]
        options[:output] = options[:input] unless options.has_key?(:output)
        watchers << ::Guard::Watcher.new(%r{^#{ options.delete(:input) }/(.+\.s[ac]ss)$})
      end

      options = DEFAULTS.merge(options)
      options[:load_paths] += load_paths

      @runner = Runner.new(watchers, options)
      super(watchers, options)
    end

    # If option set to run all on start, run all when started.
    #
    # @raise [:task_has_failed]
    def start
      run_all if options[:all_on_start]
    end

    # Build all files being watched
    #
    # @raise [:task_has_failed]
    def run_all
      files = Dir.glob('**/*.s[ac]ss').reject {|f| partial?(f) }
      run_on_changes Watcher.match_files(self, files)
    end

    # Build the files given. If a 'partial' file is found (begins with '_') calls
    # {#run_all} as we don't know which other files need to use it.
    #
    # @param paths [Array<String>]
    # @raise [:task_has_failed]
    def run_on_changes(paths)
      return run_all if paths.any? {|f| partial?(f) }

      changed_files, success = @runner.run(paths)
      notify changed_files

      throw :task_has_failed unless success
    end

    # Restore previous behaviour, when a file is removed we don't want to call
    # {#run_on_changes}.
    def run_on_removals(paths)

    end

    # Notify other guards about files that have been changed so that other guards can
    # work on the changed files.
    #
    # @param changed_files [Array<String>]
    def notify(changed_files)
      ::Guard.guards.each do |guard|
        paths = Watcher.match_files(guard, changed_files)
        guard.run_on_change(paths) unless paths.empty?
      end
    end

    def partial?(path)
      File.basename(path)[0,1] == "_"
    end

  end
end
