require 'guard'
require 'guard/guard'

require 'sass'

module Guard
  class Sass < Guard
  
    VERSION = '0.0.1'
    attr_accessor :options
        
    
    # Gets the actual files in the path, ignores files beginning with
    # an underscore as you expect from sass.
    #
    # @param paths [Array] list of paths which have been modified
    # @return [Array] files found
    #
    def get_sass_files(paths)
      files = []
      paths.each do |path|
        files =  Dir.glob File.join(path, '*')
      end
      files.delete_if {|i| File.basename(i)[0] == "_"}
      files
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
      engine = ::Sass::Engine.new(content, {:syntax => type})
      engine.render
    end
    
    # Get the file path to output the css based on the file being 
    # built.
    #
    # @param file [String] path to file being built
    # @return [String] path to file where output should be written
    #
    def get_output(file)
      folder = File.dirname(file).split('/')[0..-2]
      r = File.join folder, @options[:output], File.basename(file).split('.')[0]
      r << '.css'
    end
    
    
    # ================
    # = Guard method =
    # ================
  
    def start
      @options[:output] = options[:output] || 'css'
    end
    
    # Build the paths given
    def run_on_change(paths)
      files = get_sass_files(paths)
      files.each do |file|
        File.open(get_output(file), 'w') {|f| f.write(build_sass(file)) }
      end
    end

  end
end