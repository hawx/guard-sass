# Guard-Sass

guard-sass compiles or validates your sass (and scss) files automatically when changed.

## Install

You will need to have [guard](http://github.com/guard/guard) to continue, so install it now!

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

### Ruby project

In a Ruby project you want to configure your input and output directories.

```ruby
guard 'sass', :input => 'sass', :output => 'styles'
```

If your output directory is the same as the input directory, you can simply skip it:

```ruby
guard 'sass', :input => 'styles'
```

### Rails app with the asset pipeline

With the introduction of the [asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html)
in Rails 3.1 there is no need to compile your Sass stylesheets with this Guard. However if you
like to have instant validation feedback (preferably with a Growl notification) directly after
you save a change, then you may want still use this Guard and just skip the generation of the
output file:

```ruby
guard 'sass', :input => 'app/assets/stylesheets', :noop => true
```

This give you a faster compilation feedback compared to making a subsequent request to your
Rails application. If you just want to be notified when an error occurs you can hide the
success compilation message:

```ruby
guard 'sass', :input => 'app/assets/stylesheets', :noop => true, :hide_success => true
```

### Rails app without the asset pipeline

Without the asset pipeline you just define an input and output directory like within a normal Ruby project:

```ruby
guard 'sass', :input => 'app/stylesheets', :output => 'public/stylesheets'
```

## Options

There following options can be passed to guard-sass:

```ruby
:input => 'sass'                    # Relative path to the input directory.
                                    # A suffix `/(.+\.s[ac]ss)` will be added to this option.
                                    # default: nil

:output => 'css'                    # Relative path to the output directory.
                                    # default: 'css' or the :input option when supplied

:notification => false              # Whether to display success and error notifications after finished.
                                    # default: true

:hide_success => true               # Disable successful compilation messages.
                                    # default: false

:shallow => true                    # Do not create nested output directories.
                                    # default: false

:style => :nested                   # Controls the output style.
                                    # Accepted options are :nested, :compact, :compressed and :expanded
                                    # default: :nested

:load_paths => ['sass/partials']    # Paths for sass to find imported sass files from.
                                    # default: all directories under current

:noop => true                       # No operation: Do not write output file
                                    # default: false

:debug_info_ => true                # File and line number info for FireSass.
                                    # default: false
```

### Output short notation

guard-sass also has a short notation like [guard-coffeescript][gcs], this let's you define
an input folder (with an optional output folder) and the watcher is defined for you.

```ruby
guard 'sass', :input => 'sass', :output => 'styles'
# or
guard 'sass', :input => 'stylesheets'
```

These are equivalent to

```ruby
guard 'sass', :output => 'styles' do
  watch %r{^sass/(.+\.s[ac]ss)$}
end

guard 'sass' do
  watch %r{^stylesheets/(.+\.s[ac]ss)$}
end
```

### Nested directories

The Guard detects by default nested directories and creates these within the output directory.
The detection is based on the match of the watch regular expression:

A file

```bash
/app/stylesheets/form/button.sass
```

that has been detected by the watch

```ruby
watch(%r{^app/stylesheets/(.+\.s[ac]ss)$})
```

with an output directory of

```ruby
:output => 'public/stylesheets'
```

will be compiled to

```bash
public/stylesheets/form/button.css
```

Note the parenthesis around the `.+\.s[ac]ss`. This enables guard-sass to place the full
path that was matched inside the parenthesis into the proper output directory.

This behavior can be switched off by passing the option `:shallow => true` to the Guard, so that
all stylesheets will be compiled directly to the output directory.

## Development

- Source hosted at [GitHub](https://github.com/hawx/guard-sass)
- Report issues and feature requests to [GitHub Issues](https://github.com/hawx/guard-sass/issues)

Pull requests are very welcome!

For questions please join us on our [Google group](http://groups.google.com/group/guard-dev) or
on `#guard` (irc.freenode.net).

## Contributors

Have a look at the [GitHub contributor](https://github.com/hawx/guard-sass/contributors) list to
see all contributors.

Since this Guard is very close to [guard-coffeescript][gcs],
some features have been incorporated into guard-sass.

## License

(The MIT License)

Copyright (c) 2010 - 2011 Joshua Hawxwell

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

[gcs]: http://github.com/netzpirat/guard-coffeescript "guard-coffeescript"
[gdoc]: https://github.com/guard/guard#readme