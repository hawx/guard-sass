# Guard-Sass

## Install

You will need to have [guard](http://github.com/guard/guard) to contine, so install it now!.

Install the gem with:

    gem install guard-sass

Add it to your Gemfile:

    gem 'guard-sass'

And finally add a basic setup to your Guardfile with:

    guard init sass


## Usage

A guard extension that allows you to easily rebuild .sass (or .scss) files when changed.

    guard 'sass' do
      watch('^sass/(.*)')
    end

Defaults to writing to 'css/' but this can be changed....

    guard 'sass', :output => 'styles' do
      watch('^sass/(.*)')
    end
