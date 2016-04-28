require 'sass'
require 'sass/plugin'

require 'guard'
require 'guard/plugin'
require 'guard/watcher'

module Guard
  class Sass < Plugin

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

    # @param options [Hash]
    # @option options [String] :input
    #   The input directory
    #
    # @option options [String] :output
    #   The output directory
    #
    # @option options [String] :extension
    #   The extension to replace the '.s[ac]ss' part of the file name with
    #
    # @option options [Array<String>] :load_paths
    #   List of directories you can @import from
    #
    # @option options [Boolean] :shallow
    #   Whether to output nested directories
    #
    # @option options [Boolean] :line_numbers
    #   Whether to output human readable line numbers as comments in the file
    #
    # @option options [Boolean] :debug_info
    #   Whether to output file and line number info for FireSass
    #
    # @option options [Boolean] :noop
    #   Whether to run in "asset pipe" mode, no ouput, just validation
    #
    # @option options [Boolean] :hide_success
    #   Whether to hide all success messages
    #
    # @option options [Boolean] :resolve
    #   Choose when to resolve dependencies to the changed file.
    #
    #   When set to :none, only changed files are compiled.
    #
    #   When set to :partials, if a partial is changed any files using that
    #   partial will be recompiled.
    #
    #   When set to :all, when any file is changed it will trigger compilation
    #   of any other file that includes it.
    #
    # @option options [Symbol] :style
    #   See http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#output_style
    #
    def initialize(options={})
      load_paths = options.delete(:load_paths) || []

      if options[:input]
        load_paths << options[:input]
        options[:output] = options[:input] unless options.has_key?(:output)
        options[:watchers] << ::Guard::Watcher.new(%r{^#{ options[:input] }/(.+\.s[ac]ss)$})
      end
      options = DEFAULTS.merge(options)

      options[:load_paths] += load_paths
      options[:load_paths].flatten!

      options[:resolve] ||= :partials if options.has_key?(:smart_partials)

      @formatter = Formatter.new(:hide_success => options[:hide_success])
      @runner = Runner.new(options[:watchers], @formatter, options)
      super(options)
    end

    # @return [Array<String>] Paths of all sass/scss files
    def files
      Watcher.match_files self, Dir['**/*.s[ac]ss']
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
      __run_paths files.reject {|f| partial?(f) }
    end

    # Builds the files given.
    #
    # If a partial file is found it will attempt to compile any files dependent
    # on it. If :resolve is set to :partials this will involve searching for all
    # files that import it, otherwise #run_all will be called.
    #
    # If :resolve is set to :all then this will trigger compilation of any files
    # dependent on the changed files as well.
    #
    # Fires a `:run_on_changes_end` hook with a `changed_files` array and
    # a `success` bool as parameters.
    #
    # @param paths [Array<String>]
    # @raise [:task_has_failed]
    def run_on_changes(paths)
      partials, paths = paths.partition {|f| partial?(f) }

      if partials.any?
        if options[:resolve] == :partials
          paths += @runner.owners(partials)
        else
          paths = files
        end
      elsif options[:resolve] == :all
        paths += @runner.owners(paths)
      end

      __run_paths paths.reject {|f| partial?(f) }
    end

    # Restore previous behaviour, when a file is removed we don't want to call
    # {#run_on_changes}.
    def run_on_removals(paths)

    end

    private

    def __run_paths(paths)
      changed_files, success = @runner.run(paths)

      hook :end, Array(changed_files), success

      throw :task_has_failed unless success
    end

    def resolve_to_owners(paths)
      files.select do |file|
        deps = []
         begin
           deps = ::Sass::Engine.for_file(file, @options)
                  .dependencies
                  .collect {|dep| dep.options[:filename] }

           (deps & paths).any?

         rescue ::Sass::SyntaxError => e
           message = "Resolving partial owners of #{file} failed"
           @formatter.error "Sass > #{e.sass_backtrace_str(file)}", notification: message
           false
         end
      end
    end

    # @return Whether +path+ is a partial
    def partial?(path)
      File.basename(path).start_with? '_'
    end

  end
end

require 'guard/sass/runner'
require 'guard/sass/formatter'
