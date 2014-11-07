require 'spec_helper'

describe Guard::Sass::Runner do

  subject { Guard::Sass::Runner }

  let(:watcher)   { Guard::Watcher.new('^(.*)\.s[ac]ss$') }
  let(:formatter) { Guard::Sass::Formatter.new }
  let(:defaults)  { Guard::Sass::DEFAULTS }

  before do
    FileUtils.stub :mkdir_p
    File.stub :open
    IO.stub(:read).and_return ''
    Guard.stub(:listener).and_return stub('Listener')
  end

  describe '#run' do

    it 'returns a list of changed files' do
      subject.new([watcher], formatter, defaults).run(['a.sass'])[0].should == ['css/a.css']
    end

    context 'if errors when compiling' do
      subject { Guard::Sass::Runner.new([watcher], formatter, defaults) }

      before do
        $_stderr, $stderr = $stderr, StringIO.new
        IO.stub(:read).and_return('body { color: red;')
      end

      after { $stderr = $_stderr }

      it 'shows a warning message' do
        formatter.should_receive(:error).with('Sass > Syntax error: Invalid CSS after "body ": expected selector, was "{ color: red;"
        on line 1 of a.sass', :notification => 'rebuild of a.sass failed')
        subject.run(['a.sass'])
      end

      it 'returns false' do
        subject.run(['a.sass'])[1].should == false
      end

    end

    context 'if no errors when compiling' do
      subject { Guard::Sass::Runner.new([watcher], formatter, defaults) }

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

      mock_engine = mock(::Sass::Engine)
      ::Sass::Engine.should_receive(:new).with('', {
        :filesystem_importer => Guard::Sass::Importer,
        :load_paths          => ['sass'],
        :style               => :nested,
        :debug_info          => false,
        :line_numbers        => false,
        :syntax              => :sass,
        :filename            => 'a.sass',
        :all_on_start        => false,
        :output              => "css",
        :extension           => ".css",
        :shallow             => false,
        :noop                => false,
        :hide_success        => false
      }).and_return(mock_engine)
      mock_engine.should_receive(:render)

      subject.new([watcher], formatter, defaults).run(['a.sass'])
    end

  end

end
