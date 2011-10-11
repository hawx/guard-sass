require 'guard'
require 'guard/guard'
require 'guard/watcher'

module Guard
  class Sass < Guard
  
    autoload :Runner,    'guard/sass/runner'
    autoload :Formatter, 'guard/sass/formatter'

    DEFAULTS = {
      :output       => 'css',
      :style        => :nested,
      :shallow      => false,
      :debug_info   => false,
      :noop         => false,
      :hide_success => false,
      :load_paths   => Dir.glob('**/**').find_all {|i| File.directory?(i) }
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
    # @option options [Boolean] :debug_info
    #   Whether to output file and line number info for FireSass
    # @option options [Boolean] :noop
    #   Whether to run in "asset pipe" mode, no ouput, just validation
    # @option options [Boolean] :hide_success
    #   Whether to hide all success messages
    # @option options [Symbol] :style
    #   See http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#output_style
    def initialize(watchers=[], options={})
      if options[:input]
        options[:output] = options[:input] unless options.has_key?(:output)
        watchers << ::Guard::Watcher.new(%r{^#{options.delete(:input)}/(.+\.s[ac]ss)$})
      end
      
      options = DEFAULTS.merge(options)
      @runner = Runner.new(watchers, options)
      super(watchers, options)
    end

    # ================
    # = Guard method =
    # ================

    # Build all files being watched
    #
    # @return [Boolean] No errors?
    def run_all
      run_on_change(Watcher.match_files(self, Dir.glob(File.join('**', '[^_]*.*'))))
    end
    
    # Build the files given. If a 'partial' file is found (begins with '_') calls
    # {#run_all} as we don't know which other files need to use it.
    # 
    # @param paths [Array<String>]
    # @return [Boolean] No errors?
    def run_on_change(paths)   
      partials = paths.select {|f| File.basename(f)[0,1] == "_" }
      return run_all unless partials.empty?
      
      changed_files, success = @runner.run(paths)
      
      notify changed_files
      success
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

  end
end
