require 'guard'
require 'guard/guard'

require 'sass'

module Guard
  class Sass < Guard
  
    VERSION = '0.0.6'
    attr_accessor :options
    
    def initialize(watchers = [], options = {})
      @watchers, @options = watchers, options
      @options[:output] ||= 'css'
      @options[:load_paths] ||= Dir.glob('**/**').find_all {|i| File.directory?(i)}
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
      patterns = @watchers.map {|w| w.pattern}
      files = Dir.glob('**/*.*')
      r = []
      files.each do |file|
        patterns.each do |pattern|
          r << file if file.match(Regexp.new(pattern))
        end
      end
      run_on_change(r)
    end
    
    # Build the files given
    def run_on_change(paths)
      paths.each do |file|
        unless File.basename(file)[0] == "_"
          File.open(get_output(file), 'w') {|f| f.write(build_sass(file)) }
        end
        puts "-> rebuilt #{file}"
      end
    end

  end
end