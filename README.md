# Guard-Sass

guard-sass compiles your sass (and scss) files automatically when changed.

## Install

You will need to have [guard](http://github.com/guard/guard) to continue, so install it now!.

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

These are equivelant to

```ruby
guard 'sass', :output => 'styles' do
  watch %r{^sass/(.+\.s[ac]ss)$}
end

guard 'sass' do
  watch %r{^stylesheets/(.+\.s[ac]ss)$}
end
```


## Options

```ruby
:input => 'sass'                    # Relative path to the input directory
:output => 'css'                    # Relative path to the output directory
:notification => false              # Whether to display notifications after finished,
                                    #  default: true
:shallow => true                    # Whether to output nested directories or just put css
                                    #  directly in output folder, default: false
:style => :nested                   # Controls the output style, by default :nested
                                    #  accepted options are :nested, :compact, :compressed and :expanded
:load_paths => ['sass/partials']    # Paths for sass to find imported sass files from,
                                    #  default: all directories under current
:debug_info_ => true                # File and line number info for FireSass, default: false
```


## [Contributors](https://github.com/hawx/guard-sass/contributors)


[gcs]: http://github.com/netzpirat/guard-coffeescript "guard-coffeescript"