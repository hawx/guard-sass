require 'guard'
require 'guard/guard'
require 'guard/watcher'

require 'sass'

module Guard
  class Sass < Guard
  
    VERSION = '0.0.6'
    attr_accessor :options
    
    def initialize(watchers = [], options = {})
      super(watchers, {
        :output => 'css',
        :load_paths => Dir.glob('**/**').find_all {|i| File.directory?(i)}
      }.merge(options))
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
      engine = ::Sass::Engine.new(content, {:syntax => type, :load_paths => @options[:load_paths]})
      engine.render
    end
    
    # Get the file path to output the css based on the file being 
    # built.
    #
    # @param file [String] path to file being built
    # @return [String] path to file where output should be written
    #
    def get_output(file)
      folder = File.join File.dirname(file), '..', @options[:output]
      FileUtils.mkdir_p folder
      r = File.join folder, File.basename(file).split('.')[0]
      r << '.css'
    end
    
    
    # ================
    # = Guard method =
    # ================
    
    # Build all files being watched
    def run_all
      run_on_change(Watcher.match_files(self, Dir.glob(File.join('**', '*.*'))))
    end
    
    # Build the files given
    def run_on_change(paths)
      changed_files = paths.reject{ |f| File.basename(f)[0] == "_" }.map do |file|
        css_file = get_output(file)
        begin
          File.open(css_file, 'w') {|f| f.write(build_sass(file)) }
          ::Guard::UI.info "-> rebuilt #{file}", :reset => true
          css_file
        rescue ::Sass::SyntaxError => e
          ::Guard::UI.error "Sass > #{e.sass_backtrace_str(file)}"
        end
      end.compact
      notify changed_files
    end
    
    def notify(changed_files)
      ::Guard.guards.each do |guard|
        paths = Watcher.match_files(guard, changed_files)
        guard.run_on_change paths unless paths.empty?
      end
    end

  end
end