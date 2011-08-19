require 'spec_helper'

describe Guard::Sass do
  subject { Guard::Sass.new }

  describe "#initialize" do
    it "should set default output path" do
      subject.options[:output].should == 'css'
    end

    it "should set default style" do
      subject.options[:style].should == :nested
    end

    it "should be able to set the style" do
      gs = Guard::Sass.new(nil, {:style => 'compressed'})
      gs.options[:style].should == 'compressed'
    end
  end

  describe "#build_sass" do
    it "should convert sass to css" do
      file = "sass-test/_sass/screen.sass"

      res = <<EOS
body {
  color: red; }

html {
  color: blue; }

.error, .badError {
  border: 1px red;
  background: #ffdddd; }

.error.intrusion, .intrusion.badError {
  font-size: 1.3em;
  font-weight: bold; }

.badError {
  border-width: 3px; }
EOS

      subject.build_sass(file).should == res
    end

    it "should convert scss to css" do
      file = "sass-test/_sass/print.scss"

      res = <<EOS
.error, .badError {
  border: 1px #f00;
  background: #fdd; }

.error.intrusion, .intrusion.badError {
  font-size: 1.3em;
  font-weight: bold; }

.badError {
  border-width: 3px; }
EOS

      subject.build_sass(file).should == res
    end

    it "should add debugging information" do
      file = "sass-test/_sass/print.scss"

      res = <<'EOS'
@media -sass-debug-info{filename{font-family:}line{font-family:\000031}}
.error, .badError {
  border: 1px #f00;
  background: #fdd; }

@media -sass-debug-info{filename{font-family:}line{font-family:\000035}}
.error.intrusion, .intrusion.badError {
  font-size: 1.3em;
  font-weight: bold; }

@media -sass-debug-info{filename{font-family:}line{font-family:\0000310}}
.badError {
  border-width: 3px; }
EOS

      Guard::Sass.new([], {:debug_info => true}).build_sass(file).should == res
    end
  end

  describe "#get_output" do
    before do
      m = mock("listener")
      m.stub!(:directory).and_return("sass-test")
      ::Guard.stub(:listener).and_return(m)
    end

    it "should change extension to css" do
      subject.options[:output] = "css"
      r = subject.get_output("sass-test/_sass/screen.sass")
      r[-3..-1].should == "css"
    end

    it "should change the folder to /css (by default)" do
      subject.options[:output] = "css"
      r = subject.get_output("sass-test/_sass/screen.sass")
      File.dirname(r).should == "sass-test/css"
    end

    it "should not change the file name" do
      subject.options[:output] = "csS"
      r = subject.get_output("sass-test/_sass/screen.sass")
      File.basename(r)[0..-5].should == "screen"
    end
  end

  describe "#ignored?" do
    it "is true if file begins with _" do
      subject.ignored?("some/dir/_file.sass").should be_true
    end

    it "is false if file does not begin with _" do
      subject.ignored?("some/dir/file.sass").should be_false
    end
  end

  describe "#run_all" do
    it "should rebuild all files being watched" do
      Guard::Sass.stub(:run_on_change).with([]).and_return([])
      Guard.stub(:guards).and_return([subject])
      subject.run_all
    end
  end

  describe "#run_on_change" do
    before do
      subject.stub!(:notify)
      m = mock("listener")
      m.stub!(:directory).and_return("sass-test")
      ::Guard.stub(:listener).and_return(m)
    end

    it "calls #run_all if partials changed" do
      subject.should_receive(:run_all).and_return(nil)
      subject.run_on_change(["some/_partial.sass"])
    end

    it "builds the sass files" do
      subject.should_receive(:build_sass).and_return("text")
      File.any_instance.should_receive(:write).with("text")
      subject.run_on_change(["some/file.sass"])
    end

    it "displays warning if sass syntax error raised" do
      subject.should_receive(:build_sass).and_raise(::Sass::SyntaxError.new('hio'))
      ::Guard::UI.should_receive(:error)
      ::Guard::Notifier.should_receive(:notify)
      subject.run_on_change(["some/bad_file.sass"])
    end
  end

  describe "#notify" do
    it "should notify other guards upon completion" do
      other_guard = mock('guard')
      other_guard.should_receive(:watchers).and_return([])
      Guard.stub(:guards).and_return([subject, other_guard])
      subject.notify([])
    end
  end

  describe "#styling" do
    it "should be able to change the style" do
      subject.options[:style] = :compressed

      subject.options[:style].should == :compressed
    end

    it "should be nested by default" do
      file = "sass-test/_sass/screen.sass"

      res = <<-EOS
body {
  color: red; }

html {
  color: blue; }

.error, .badError {
  border: 1px red;
  background: #ffdddd; }

.error.intrusion, .intrusion.badError {
  font-size: 1.3em;
  font-weight: bold; }

.badError {
  border-width: 3px; }
EOS

      subject.build_sass(file).should == res
    end

    it "should accept compact" do
      subject.options[:style] = :compact

      file = "sass-test/_sass/screen.sass"

      res = <<-EOS
body { color: red; }

html { color: blue; }

.error, .badError { border: 1px red; background: #ffdddd; }

.error.intrusion, .intrusion.badError { font-size: 1.3em; font-weight: bold; }

.badError { border-width: 3px; }
EOS

      subject.build_sass(file).should == res
    end

    it "should accept compressed" do
      subject.options[:style] = :compressed

      file = "sass-test/_sass/screen.sass"

      res = "body{color:red}html{color:blue}.error,.badError{border:1px red;background:#fdd}.error.intrusion,.intrusion.badError{font-size:1.3em;font-weight:bold}.badError{border-width:3px}\n"

      subject.build_sass(file).should == res
    end

    it "should accept expanded" do
      subject.options[:style] = :expanded

      file = "sass-test/_sass/screen.sass"

      res = <<-EOS
body {
  color: red;
}

html {
  color: blue;
}

.error, .badError {
  border: 1px red;
  background: #ffdddd;
}

.error.intrusion, .intrusion.badError {
  font-size: 1.3em;
  font-weight: bold;
}

.badError {
  border-width: 3px;
}
EOS

      subject.build_sass(file).should == res
    end
  end
end
