# Guard-Sass

guard-sass compiles your sass (and scss) files automatically when changed.

## Install

You will need to have [guard](http://github.com/guard/guard) to continue, so install it now!

Install the gem with:

    gem install guard-sass

Add it to your Gemfile:

    gem 'guard-sass'

And finally add a basic setup to your Guardfile with:

    guard init sass

## Usage

```ruby
guard 'sass' do
  watch(%r{^sass/(.+\.s[ac]ss)})
end
```

Defaults to writing to 'css/' but this can be changed by setting the output option

```ruby
guard 'sass', :output => 'styles' do
  watch(%r{^sass/(.+\.s[ac]ss)})
end
```

By default a file such as `sass/forms/buttons.sass` with the above guard file would be
output to `styles/forms/buttons.css` because `forms` would be matched with the parentheses.
This can be disabled by passing `:shallow => true` so that it would be written to
`styles/buttons.css` instead.

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

### With the Rails asset pipeline

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

## Options

There following options can be passed to guard-sass:

```ruby
:input => 'sass'                    # Relative path to the input directory.
                                    # A suffix `/(.+\.s[ac]ss)` will be added to this option.
                                    # default: nil

:output => 'css'                    # Relative path to the output directory.
                                    # default: the path given with the :input option

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


## [Contributors](https://github.com/hawx/guard-sass/contributors)


[gcs]: http://github.com/netzpirat/guard-coffeescript "guard-coffeescript"
