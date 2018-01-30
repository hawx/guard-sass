require 'sass'
require 'benchmark'

module Guard
  class Sass
    # Sass runner for Guard
    class Runner
      attr_reader :options

      # @param watchers [Array<Guard::Watcher>]
      # @param formatter [Guard::Sass::Formatter]
      # @param options [Hash] See Guard::Sass::DEFAULTS for available options
      def initialize(watchers, formatter, options = {})
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
      # @return [Array<Array,Array>]
      #   The files which have been changed and an array
      #  of any error messages if any errors occurred.
      def compile_files(files)
        input, output = options.values_at(:input, :output)

        short_files = files.map { |file| file.sub(%r{^#{input}/}, '') }
        max_length = short_files.map(&:length).max

        files.zip(short_files).each_with_object([[], []]) \
          do |(file, short_file), (changed_files, errors)|
            begin
              css_file = nil
              time = Benchmark.realtime do
                css_file = write_file(compile(file), get_output_dir(file), file)
              end

              short_css_file = css_file.sub(%r{^#{output}/}, '')

              message =
                if options[:noop]
                  "verified #{file} (#{time})"
                else
                  "#{short_file.ljust(max_length)} -> #{short_css_file}"
                end
              @formatter.success message, notification: message, time: time
              changed_files << css_file
            rescue ::Sass::SyntaxError => e
              message =
                "#{options[:noop] ? 'validation' : 'rebuild'} of #{file} failed"
              errors << message
              @formatter.error(
                "Sass > #{e.sass_backtrace_str(file)}",
                notification: message
              )
            end
          end
      end

      # @param file [String] Path to sass/scss file to compile
      # @return [String] Compiled css.
      def compile(file)
        sass_options = { filesystem_importer: Importer }.merge(options)

        ::Sass::Engine.for_file(file, sass_options).render
      end

      # @param file [String]
      # @return [String] Directory to write +file+ to
      def get_output_dir(file)
        folder = options[:output]

        return folder if options[:shallow]

        @watchers.each do |watcher|
          next unless (matches = watcher.match(file))
          next unless matches[1]
          break File.join(folder, File.dirname(matches[1])).gsub(%r{/\.$}, '')
        end
      end

      # Write file contents, creating directories where required.
      #
      # @param content [String] Contents of the file
      # @param dir [String] Directory to write to
      # @param file [String] Name of the file
      # @return [String] Path of file written
      def write_file(content, dir, file)
        filename =
          File.basename(file).gsub(/(\.s?[ac]ss)+/, options[:extension])
        path = File.join(dir, filename)

        unless options[:noop]
          FileUtils.mkdir_p(dir)
          File.write(path, content)
        end

        path
      end
    end
  end
end

require 'guard/sass/importer'
