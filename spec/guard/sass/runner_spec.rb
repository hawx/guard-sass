require 'spec_helper'

describe Guard::Sass::Runner do

  subject { Guard::Sass::Runner }

  let(:watcher)   { Guard::Watcher.new(/^(.*)\.s[ac]ss$/) }

  let(:formatter) {
    ::Guard::UI.stub(:error)
    ::Guard::UI.stub(:info)

    Guard::Sass::Formatter.new
  }

  let(:defaults)  { Guard::Sass::DEFAULTS }

  before do
    FileUtils.stub :mkdir_p
    File.stub :open
    IO.stub(:read).and_return ''
    Guard.stub(:listener).and_return stub('Listener')
  end

  describe '#run' do

    it 'returns a list of changed files' do
      mock_engine = mock(::Sass::Engine)
      mock_engine
        .should_receive(:render)

      ::Sass::Engine
        .should_receive(:for_file)
        .and_return(mock_engine)

      subject
        .new([watcher], formatter, defaults)
        .run(['a.sass'])[0].should == ['css/a.css']
    end

    context 'if errors when compiling' do
      subject { Guard::Sass::Runner.new([watcher], formatter, defaults) }

      before do
        $_stderr, $stderr = $stderr, StringIO.new
        IO.stub(:read).and_return('body { color: red;')

        mock_engine = mock(::Sass::Engine)
        mock_engine
          .should_receive(:render)
          .and_raise(Sass::SyntaxError.new('Err'))

        ::Sass::Engine
          .should_receive(:for_file)
          .and_return(mock_engine)
      end

      after { $stderr = $_stderr }

      it 'shows a warning message' do
        formatter
          .should_receive(:error)
          .with("Sass > Error: Err\n        on line  of a.sass",
                notification: 'rebuild of a.sass failed')

        subject.run(['a.sass'])
      end

      it 'returns false' do
        subject.run(['a.sass'])[1].should == false
      end
    end

    context 'if no errors when compiling' do
      subject { Guard::Sass::Runner.new([watcher], formatter, defaults) }

      before do
        mock_engine = mock(::Sass::Engine)
        mock_engine
          .should_receive(:render)

        ::Sass::Engine
          .should_receive(:for_file)
          .and_return(mock_engine)
      end

      it 'shows a success message' do
        formatter.should_receive(:success).with("a.sass -> a.css", instance_of(Hash))
        subject.run(['a.sass'])
      end

      it 'returns true' do
        subject.run(['a.sass'])[1].should == true
      end
    end

    it 'compiles the files' do
      Guard::Sass::DEFAULTS[:load_paths] = ['sass']

      opts = {
        :filesystem_importer => Guard::Sass::Importer,
        :load_paths          => ['sass'],
        :style               => :nested,
        :debug_info          => false,
        :line_numbers        => false,
        :all_on_start        => false,
        :output              => "css",
        :extension           => ".css",
        :shallow             => false,
        :noop                => false,
        :hide_success        => false
      }

      mock_engine = mock(::Sass::Engine)
      ::Sass::Engine
        .should_receive(:for_file).with('a.sass', opts)
        .and_return(mock_engine)

      mock_engine.should_receive(:render)

      subject.new([watcher], formatter, defaults).run(['a.sass'])
    end

  end

end
