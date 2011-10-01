require 'spec_helper'

describe Guard::Sass::Runner do

  subject { Guard::Sass::Runner }
  
  let(:watcher)   { Guard::Watcher.new('^(.*)\.s[ac]ss$') }
  let(:formatter) { subject.instance_variable_get(:@formatter) }
  let(:defaults)  { Guard::Sass::DEFAULTS }
  
  before do
    FileUtils.stub :mkdir_p
    File.stub :open
    IO.stub(:read).and_return('')
  end
  
  
  describe '#run' do
  
    it 'returns a list of changed files' do
      subject.new([watcher], defaults).run(['a.sass'])[0].should == ['css/a.css']
    end
    
    context 'if errors when compiling' do
      subject { Guard::Sass::Runner.new([watcher], defaults) }
      
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
      subject { Guard::Sass::Runner.new([watcher], defaults) }
    
      it 'shows a success message' do
        formatter.should_receive(:success).with('-> compiled a.sass to css/a.css',
          :notification => 'compiled a.sass to css/a.css')
        subject.run(['a.sass'])
      end
      
      it 'returns true' do
        subject.run(['a.sass'])[1].should == true
      end
    end
  
    it 'compiles the files' do
      a = Guard::Sass::DEFAULTS[:load_paths]
      Guard::Sass::DEFAULTS[:load_paths] = ['sass']
      
      mock_engine = mock(::Sass::Engine)
      ::Sass::Engine.should_receive(:new).with('', {
        :syntax => :sass, :load_paths => ['sass'], 
        :style => :nested, :debug_info => false
      }).and_return(mock_engine)
      mock_engine.should_receive(:render)
      
      subject.new([watcher], defaults).run(['a.sass'])

      Guard::Sass::DEFAULTS[:load_paths] = a
    end
  
  end

end