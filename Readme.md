# Guard-Sass

A guard extension that allows you to easily rebuild .sass (or .scss) files when changed.

    guard 'sass' do
      watch('^sass/(.*)')
    end

Defaults to writing to 'css/' but this can be changed....

    guard 'sass', :output => 'styles' do
      watch('^sass/(.*)')
    end
