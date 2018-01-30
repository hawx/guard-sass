require 'spec_helper'

describe Guard::Sass::Runner do
  subject { Guard::Sass::Runner }

  let(:watcher)   { Guard::Watcher.new(/^(.*)\.s[ac]ss$/) }
  let(:formatter) { Guard::Sass::Formatter.new }
  let(:defaults)  { Guard::Sass::DEFAULTS }

  let(:notifier)  { Guard::Notifier }
  let(:ui)        { Guard::Compat::UI }

  before do
    allow(FileUtils).to receive(:mkdir_p).with('css')
    # for Sass cache
    allow(FileUtils).to receive(:mkdir_p).and_call_original
    allow(File).to receive(:read).with('a.sass').and_return(
      "body\n  color: red"
    )
    allow(File).to receive(:write).with('css/a.css', anything)
    allow(Guard).to receive(:listener).and_return('Listener')
  end

  after do
    FileUtils.rm_rf '.sass-cache'
  end

  describe '#run' do
    before do
      allow(notifier).to receive(:notify).once
    end

    it 'returns a list of changed files' do
      allow(ui).to receive(:info).once
      expect(
        subject.new([watcher], formatter, defaults).run(['a.sass'])[0]
      )
        .to eq ['css/a.css']
    end

    context 'if errors when compiling' do
      subject { Guard::Sass::Runner.new([watcher], formatter, defaults) }

      before do
        allow(File).to receive(:read)
          .with('a.sass').and_return("body\n  color: red;")

        allow(ui).to receive(:error).once
      end

      it 'shows an error message' do
        expect(formatter).to receive(:error)
          .with(
            'Sass > Error: Invalid CSS after "red":' \
              ' expected expression (e.g. 1px, bold), was ";"' \
              "\n        on line 2 of a.sass",
            notification: 'rebuild of a.sass failed'
          )
          .once
        subject.run(['a.sass'])
      end

      it 'returns false' do
        expect(subject.run(['a.sass'])[1]).to eq false
      end
    end

    context 'if no errors when compiling' do
      before do
        allow(ui).to receive(:info).once
      end

      subject { Guard::Sass::Runner.new([watcher], formatter, defaults) }

      it 'shows a success message' do
        expect(formatter).to receive(:success).with(
          'a.sass -> a.css', instance_of(Hash)
        )
        subject.run(['a.sass'])
      end

      it 'returns true' do
        expect(subject.run(['a.sass'])[1]).to eq true
      end
    end

    it 'compiles the files' do
      Guard::Sass::DEFAULTS[:load_paths] = ['sass']

      sass_engine = double(:sass_engine)

      allow(ui).to receive(:info).once

      allow(::Sass::Engine).to receive(:new)
        .with(
          "body\n  color: red",
          filesystem_importer: Guard::Sass::Importer,
          load_paths:          ['sass'],
          style:               :nested,
          debug_info:          false,
          line_numbers:        false,
          syntax:              :sass,
          filename:            'a.sass',
          all_on_start:        false,
          output:              'css',
          extension:           '.css',
          shallow:             false,
          noop:                false,
          hide_success:        false
        )
        .and_return(sass_engine)

      expect(sass_engine).to receive(:render)

      subject.new([watcher], formatter, defaults).run(['a.sass'])
    end
  end
end
