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
  watch(%r{^sass/.+\.s[ac]ss})
end
```

Defaults to writing to 'css/' but this can be changed....

```ruby
guard 'sass', :output => 'styles' do
  watch(%r{^sass/.+\.s[ac]ss})
end
```

guard-sass also has a short notation like [guard-coffeescript][gcs], this let's you define 
an input folder (with an optional output folder) and the watcher is defined for you.

```ruby
guard 'sass', :input => 'sass', :output => 'css'
# or
guard 'sass', :input => 'stylesheets'
```


## Options

```ruby
:input => 'sass'                    # Relative path to the input directory
:output => 'css'                    # Relative path to the output directory
:notification => false              # Whether to display notifications after finished,
                                    #  default: true
:load_paths => ['sass/partials']    # Paths for sass to find imported sass files from,
                                    #  default: all directories under current
```


## Contributors

- snappycode (http://github.com/snappycode)
- sauliusg (http://github.com/sauliusg)



[gcs]: http://github.com/netzpirat/guard-coffeescript "guard-coffeescript"