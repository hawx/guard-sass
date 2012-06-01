# Guard-Sass

guard-sass compiles or validates your sass (and scss) files automatically when
changed.


## Install

You will need to have [guard](http://github.com/guard/guard) to continue, so
install it now!

Install the gem with:

    gem install guard-sass

Add it to your Gemfile:

    gem 'guard-sass'

And finally add a basic setup to your Guardfile with:

    guard init sass


## Usage

Please read the [Guard usage documentation][gdoc].


## Guardfile

guard-sass can be adapted to all kind of projects. Please read the
[Guard documentation][gdoc] for more information about the Guardfile DSL.

### Ruby Project

In a Ruby project you want to configure your input and output directories.

    guard 'sass', :input => 'sass', :output => 'styles'

If your output directory is the same as the input directory, you can simply skip it:

    guard 'sass', :input => 'styles'

### Rails App With the Asset Pipeline

With the introduction of the [asset pipeline][rpipe] in Rails 3.1 there is no
need to compile your Sass stylesheets with this Guard. However, if you would
still like to have feedback on the validation of your stylesheets (preferably
with a Growl notification) directly after you save a change, then you can still
use this Guard and simply skip generation of the output file:

    guard 'sass', :input => 'app/assets/stylesheets', :noop => true

This gives you (almost) immediate feedback on whether the changes made are valid,
and is much faster than making a subsequent request to your Rails application.
If you just want to be notified when an error occurs you can hide the success
compilation message:

    guard 'sass',
      :input => 'app/assets/stylesheets',
      :noop => true,
      :hide_success => true

### Rails App Without the Asset Pipeline

Without the asset pipeline you just define an input and output directory as in
a normal Ruby project:

    guard 'sass', :input => 'app/stylesheets', :output => 'public/stylesheets'

### Output Extensions

It is standard practice in Rails 3.1 to write sass/scss files with the extension
`.css.sass` to prevent these being written as `.css.sass.css` you need to set
the `:extension` option like so:

    guard 'sass', :input => 'styles', :extension => ''


## Options

The following options can be passed to guard-sass:

    :input => 'sass'                    # Relative path to the input directory.
                                        # A suffix `/(.+\.s[ac]ss)` will be added to this option.
                                        # default: nil

    :output => 'stylesheets'            # Relative path to the output directory.
                                        # default: 'css' or the :input option when supplied

    :all_on_start => true               # Compiles all sass files on start
                                        # default: false

    :extension => ''                    # Extension used for written files.
                                        # default: '.css'

    :hide_success => true               # Disable successful compilation messages.
                                        # default: false

    :shallow => true                    # Do not create nested output directories.
                                        # default: false

    :style => :nested                   # Controls the output style. Accepted options are :nested,
                                        # :compact, :compressed and :expanded
                                        # default: :nested

    :load_paths => ['sass/partials']    # Paths for sass to find imported sass files from.
                                        # default: template locations provided by the sass gem

    :noop => true                       # No operation: Do not write output file
                                        # default: false

    :line_numbers => true               # Add human readable source filname and line number
                                        # information as comments.
                                        # default: false

    :debug_info => true                 # File and line number info for FireSass.
                                        # default: false

### Output Short Notation

guard-sass also has a short notation like [guard-coffeescript][gcs], this lets
you define an input folder (with an optional output folder) automatically creating
the required watcher.

    guard 'sass', :input => 'sass', :output => 'styles'
    # or
    guard 'sass', :input => 'stylesheets'

These are equivalent to

    guard 'sass', :output => 'styles' do
      watch %r{^sass/(.+\.s[ac]ss)$}
    end

    guard 'sass' do
      watch %r{^stylesheets/(.+\.s[ac]ss)$}
    end

### Nested Directories

By default the guard detects nested directories and writes files into the output
directory with the same structure.

The Guard detects by default nested directories and creates these within the
output directory. The detection is based on the match of the watch regular expression:

A file

    /app/stylesheets/form/button.sass

that has been detected by the watch

    watch(%r{^app/stylesheets/(.+\.s[ac]ss)$})

with an output directory of

    :output => 'public/stylesheets'

will be compiled to

    public/stylesheets/form/button.css

Note the parenthesis around `.+\.s[ac]ss`. This enables guard-sass to place
the full path that was matched inside the parenthesis into the proper output directory.

This behaviour can be switched off by passing the option `:shallow => true` to the
Guard, so that all stylesheets will be compiled directly to the output directory.
So the previous example would have compiled to `public/stylesheets/button.css`.


## Development

- Source hosted at [GitHub](https://github.com/hawx/guard-sass)
- Report issues and feature requests to [GitHub Issues][issues]

Pull requests are very welcome!

For questions please join us on our [Google group][ggroup] or
on `#guard` (irc.freenode.net).


## Contributors

Have a look at the [GitHub contributor][contrib] list to see all contributors.

Since this Guard is very close to [guard-coffeescript][gcs], some features have been
incorporated into guard-sass.


## License

(The MIT License)

Copyright (c) 2010 - 2012 Joshua Hawxwell

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


[gcs]:     http://github.com/netzpirat/guard-coffeescript
[gdoc]:    http://github.com/guard/guard#readme
[rpipe]:   http://guides.rubyonrails.org/asset_pipeline.html
[issues]:  http://github.com/hawx/guard-sass/issues
[ggroup]:  http://groups.google.com/group/guard-dev
[contrib]: http://github.com/hawx/guard-sass/contributors
