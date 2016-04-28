require 'spec_helper'

describe Guard::Sass do

  subject { ::Guard::Sass.new(watchers: [Guard::Watcher.new(/(.*)\.s[ac]ss/)]) }

  let(:formatter) { mock(::Guard::Sass::Formatter) }
  let(:runner)    { mock(::Guard::Sass::Runner) }

  before do
    subject.instance_variable_set :@runner, runner
    subject.instance_variable_set :@formatter, formatter
  end

  describe '#initialize' do
    context 'when no options given' do
      it 'uses defaults' do
        subject.options.should == Guard::Sass::DEFAULTS
      end
    end

    context 'when options given' do
      subject {
        Guard::Sass::DEFAULTS[:load_paths] = ['sass']

        opts = {
          :noop         => true,
          :hide_success => true,
          :style        => :compact,
          :line_numbers => true,
          :watchers     => []
        }
        Guard::Sass.new(opts)
      }

      it 'merges them with defaults' do
        subject.options.should == {
          :all_on_start => false,
          :output       => 'css',
          :extension    => '.css',
          :shallow      => false,
          :style        => :compact,
          :debug_info   => false,
          :noop         => true,
          :hide_success => true,
          :line_numbers => true,
          :load_paths   => ['sass']
        }
      end
    end

    context 'with an :input option' do
      subject { Guard::Sass.new(watchers: [], input: 'app/styles') }

      it 'creates a watcher' do
        subject.should have(1).watchers
      end

      it 'watches all *.s[ac]ss files' do
        subject.watchers.first.pattern.should == %r{^app/styles/(.+\.s[ac]ss)$}
      end

      context 'without an output option' do
        it 'sets the output directory to the input directory' do
          subject.options[:output].should == 'app/styles'
        end
      end

      context 'with an output option' do
        subject { Guard::Sass.new(input: 'app/styles', output: 'public/styles', watchers: []) }

        it 'uses the output directory' do
          subject.options[:output].should == 'public/styles'
        end
      end
    end

  end

  describe '#start' do
    it 'does not call #run_all' do
      subject.should_not_receive(:run_all)
      subject.start
    end

    context ':all_on_start option is true' do
      subject { Guard::Sass.new(all_on_start: true) }

      it 'calls #run_all' do
        subject.should_receive(:run_all)
        subject.start
      end
    end
  end

  describe '#run_all' do
    before { Dir.stub(:[]).and_return ['a.sass', 'b.scss', 'c.ccss', 'd.css', 'e.scsc'] }

    it 'calls #run_on_changes with all watched files' do
      subject.should_receive(:__run_paths).with(['a.sass', 'b.scss'])
      subject.run_all
    end
  end

  describe '#run_on_changes' do
    before { Dir.stub(:[]).and_return ['a.sass', 'b.scss', '_p.sass'] }

    context 'if paths contain partials' do
      it 'compiles all non-partials' do
        subject
          .should_receive(:__run_paths)
          .with(['a.sass', 'b.scss'])

        subject.run_on_changes(['_p.sass'])
      end

      context "and resolve is set to :partials" do
        before { subject.options[:resolve] = :partials }

        it 'compiles all non-partials and any files that include the partials' do
          runner
            .should_receive(:owners)
            .with(['_p.sass'])
            .and_return(['a.sass'])

          subject
            .should_receive(:__run_paths)
            .with(['b.scss', 'a.sass'])

          subject.run_on_changes(['_p.sass', 'b.scss'])
        end
      end
    end

    context 'when resolve is set to :all' do
      before { subject.options[:resolve] = :all }

      it 'compiles all changed and dependent files ' do
        runner
          .should_receive(:owners)
          .with(['b.scss'])
          .and_return(['a.sass', '_p.sass'])

        subject
          .should_receive(:__run_paths)
          .with(['b.scss', 'a.sass'])

        subject.run_on_changes(['b.scss'])
      end
    end

    it 'starts the Runner' do
      runner.should_receive(:run).with(['a.sass']).and_return([nil, true])
      subject.run_on_changes(['a.sass'])
    end
  end

end
