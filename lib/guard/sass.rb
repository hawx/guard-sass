require 'guard'
require 'guard/guard'
require 'guard/watcher'

require 'sass'

module Guard
  class Sass < Guard

    DEFAULTS = {
      :output       => 'css',     # Output directory
      :notification => true,      # Enable notifications?
      :shallow      => false,     # Output nested directories?
      :style        => :nested,   # Nested output
      :debug_info   => false,     # File and line number info for FireSass
      :noop         => false,     # Do no write output file
      :hide_success => false,     # Do not show success message
      :load_paths   => Dir.glob('**/**').find_all {|i| File.directory?(i) }
    }

    def initialize(watchers = [], options = {})
      if options[:input]
        options[:output] = options[:input] unless options.has_key?(:output)
        watchers << ::Guard::Watcher.new(%r{^#{options.delete(:input)}/(.+\.s[ac]ss)$})
      end

      super(watchers, DEFAULTS.merge(options))
    end


    # Builds the sass or scss. Determines engine to use by extension
    # of path given.
    #
    # @param file [String] path to file to build
    # @return [String] the output css
    #
    def build_sass(file)
      content = File.new(file).read
      # sass or scss?
      type = file[-4..-1].to_sym
      sass_options = {
        :syntax => type,
        :load_paths => options[:load_paths],
        :style => options[:style].to_sym,
        :debug_info => options[:debug_info],
      }
      
      ::Sass::Engine.new(content, sass_options).render
    end

    # Get the file path to output the css based on the file being
    # built.
    #
    # @param file [String] path to file being built
    # @return [String] path to file where output should be written
    #
    def get_output(file)
      folder = File.join ::Guard.listener.directory, options[:output]

      unless options[:shallow]
        watchers.product([file]).each do |watcher, file|
          if matches = file.match(watcher.pattern)
            if matches[1]
              folder = File.join(options[:output], File.dirname(matches[1])).gsub(/\/\.$/, '')
              break
            end
          end
        end
      end

      FileUtils.mkdir_p folder
      r = File.join folder, File.basename(file).split('.')[0]
      r << '.css'
    end

    def ignored?(path)
      File.basename(path)[0,1] == "_"
    end

    # ================
    # = Guard method =
    # ================

    # Build all files being watched
    def run_all
      run_on_change(Watcher.match_files(self, Dir.glob(File.join('**', '[^_]*.*'))))
    end
    
    # Build the files given
    def run_on_change(paths)
      partials = paths.select { |f| ignored?(f) }
      return run_all unless partials.empty?

      changed_files = paths.reject{ |f| ignored?(f) }.map do |file|
        css_file = get_output(file)
        begin
          contents = build_sass(file)
          if contents
            message = options[:noop] ? "verified #{file}" : "compiled #{file} to #{css_file}"
            
            File.open(css_file, 'w') {|f| f.write(contents) } unless options[:noop]
            ::Guard::UI.info "-> #{message}", :reset => true
            if options[:notification] && !options[:hide_success]
              ::Guard::Notifier.notify(message, :title => "Guard::Sass", :image => :success)
            end
          end
          css_file
        rescue ::Sass::SyntaxError => e
          ::Guard::UI.error "Sass > #{e.sass_backtrace_str(file)}"
          ::Guard::Notifier.notify(
            (options[:noop] ? 'validation' : 'rebuild') + " failed > #{e.sass_backtrace_str(file)}",
             :title => "Guard::Sass",
             :image => :error
           ) if options[:notification]
          nil
        end
      end.compact
      notify changed_files
    end

    def notify(changed_files)
      ::Guard.guards.reject{ |guard| guard == self }.each do |guard|
        paths = Watcher.match_files(guard, changed_files)
        guard.run_on_change paths unless paths.empty?
      end
    end

  end
end
