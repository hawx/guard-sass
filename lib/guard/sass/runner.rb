require 'sass'
require 'benchmark'

module Guard
  class Sass

    class Runner

      attr_reader :options

      # @param watchers [Array<Guard::Watcher>]
      # @param formatter [Guard::Sass::Formatter]
      # @param options [Hash] See Guard::Sass::DEFAULTS for available options
      def initialize(watchers, formatter, options={})
        @watchers  = watchers
        @formatter = formatter
        @options   = options
      end

      # @param files [Array<String>]
      # @return [Array<Array,Boolean>]
      def run(files)
        changed_files, errors = compile_files(files)
        [changed_files, errors.empty?]
      end

      private

      # @param files [Array<String>] Files to compile
      # @return [Array<Array,Array>] The files which have been changed and an array
      #  of any error messages if any errors occurred.
      def compile_files(files)
        errors        = []
        changed_files = []

        # Assume partials have been checked for previously, so no partials are included here
        rinput  = (options[:input]  || "").reverse
        routput = (options[:output] || "").reverse

        input   = options[:input]  || ''
        output  = options[:output] || ''

        max_length = files.map do |file|
          file.sub(/^#{input}/, '').gsub(/^\//, '').length
        end.max || 0

        files.each do |file|
          begin
            css_file = nil
            time = Benchmark.realtime do
              css_file = write_file(compile(file), get_output_dir(file), file)
            end

            short_file     = file.sub(/^#{input}/, '').gsub(/^\//, '')
            short_css_file = css_file.sub(/^#{output}/, '').gsub(/^\//, '')

            message = if options[:noop]
                        "verified #{file} (#{time})"
                      else
                        "%s -> %s" % [short_file.ljust(max_length), short_css_file]
                      end

            @formatter.success "#{message}", :notification => message, :time => time
            changed_files << css_file

          rescue ::Sass::SyntaxError => e
            message = (options[:noop] ? 'validation' : 'rebuild') + " of #{file} failed"
            errors << message
            @formatter.error "Sass > #{e.sass_backtrace_str(file)}", :notification => message
          end
        end

        [changed_files.compact, errors]
      end

      # @param file [String] Path to sass/scss file to compile
      # @return [String] Compiled css.
      def compile(file)
        sass_options = {
          :filesystem_importer => Importer,
          :load_paths          => options[:load_paths],
          :style               => options[:style],
          :debug_info          => options[:debug_info],
          :line_numbers        => options[:line_numbers]
        }

        ::Sass::Engine.for_file(file, sass_options).render
      end

      # @param file [String]
      # @return [String] Directory to write +file+ to
      def get_output_dir(file)
        folder = options[:output]

        unless options[:shallow]
          @watchers.product([file]).each do |watcher, file|
            if matches = file.match(watcher.pattern)
              if matches[1]
                folder = File.join(options[:output], File.dirname(matches[1])).gsub(/\/\.$/, '')
                break
              end
            end
          end
        end

        folder
      end

      # Write file contents, creating directories where required.
      #
      # @param content [String] Contents of the file
      # @param dir [String] Directory to write to
      # @param file [String] Name of the file
      # @return [String] Path of file written
      def write_file(content, dir, file)
        filename = File.basename(file).gsub(/(\.s?[ac]ss)+/, options[:extension])
        path = File.join(dir, filename)

        unless options[:noop]
          FileUtils.mkdir_p(dir)
          File.open(path, 'w') {|f| f.write(content) }
        end

        path
      end
    end
  end
end

require 'guard/sass/importer'