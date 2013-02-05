require 'sass'
require 'sass/plugin'

require 'guard'
require 'guard/guard'
require 'guard/watcher'

module Guard
  class Sass < Guard

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
        watchers << ::Guard::Watcher.new(%r{^#{ options[:input] }/(.+\.s[ac]ss)$})
      end
      options = DEFAULTS.merge(options)

      if compass = options.delete(:compass)
        require 'compass'
        compass = {} unless compass.is_a?(Hash)

        Compass.add_project_configuration
        Compass.configuration.project_path   ||= Dir.pwd
        Compass.configuration.images_dir       = compass[:images_dir]       || "app/assets/images"
        Compass.configuration.images_path      = compass[:images_path]      || File.join(Dir.pwd, "app/assets/images")
        Compass.configuration.http_images_path = compass[:http_images_path] || "/assets"
        Compass.configuration.http_images_dir  = compass[:http_images_dir]  || "/assets"

        Compass.configuration.http_fonts_path  = compass[:http_fonts_path]  || "/assets"
        Compass.configuration.http_fonts_dir   = compass[:http_fonts_dir]   || "/assets"

        Compass.configuration.asset_cache_buster = Proc.new {|*| {:query => Time.now.to_i} }
        options[:load_paths] ||= []
        options[:load_paths] << Compass.configuration.sass_load_paths
      end

      options[:load_paths] += load_paths
      options[:load_paths].flatten!

      @runner = Runner.new(watchers, options)
      super(watchers, options)
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
      run_on_changes files.reject {|f| partial?(f) }
    end

    def resolve_partials_to_owners(paths)
      # Get all files that might have imports
      search_files = Dir.glob("#{options[:input]}/**/*.s[ac]ss")
      search_files = Watcher.match_files(self, search_files)

      # Get owners
      owners = search_files.select do |file|
         # Get dependencies of file
         deps = ::Sass::Engine.for_file(file, @options).dependencies.collect! {|dep| dep.options[:filename] }
         # Find intersection with paths
         deps_in_paths = deps.intersection paths
         # Any paths in the dependencies?
         !deps_in_paths.empty?
      end
      # Return our resolved set of paths to recompile
      owners
    end

    def run_with_partials(paths)
      if options[:smart_partials]
        paths = resolve_partials_to_owners(paths)
        run_on_changes Watcher.match_files(self, paths) unless paths.nil?
      else
        run_all
      end
    end

    # Builds the files given. If a 'partial' file is found (name begins with
    # '_'), calls {#run_with_partials} so that files which include it are
    # rebuilt.
    #
    # @param paths [Array<String>]
    # @raise [:task_has_failed]
    def run_on_changes(paths)
      return run_with_partials(paths) if paths.any? {|f| partial?(f) }

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

    # @return Whether +path+ is a partial
    def partial?(path)
      File.basename(path).start_with? '_'
    end

  end
end

require 'guard/sass/runner'
require 'guard/sass/formatter'
