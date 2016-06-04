require 'spec_helper'

describe Guard::Sass do

  subject { ::Guard::Sass.new }

  let(:formatter) { Guard::Sass::Formatter.new }
  let(:runner) { Guard::Sass::Runner.new([], formatter) }

  before do
    subject.instance_variable_set :@runner, runner
    runner.stub :run
    Guard.stub(:listener).and_return stub('Listener')
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
      subject { Guard::Sass.new(watchers: [], all_on_start: true) }

      it 'calls #run_all' do
        subject.should_receive(:run_all)
        subject.start
      end
    end
  end

  describe '#run_all' do
    subject { Guard::Sass.new(watchers: [Guard::Watcher.new(/(.*)\.s[ac]ss/)]) }

    before do
      Dir.stub(:[]).and_return ['a.sass', 'b.scss', 'c.ccss', 'd.css', 'e.scsc']
    end

    it 'calls #run_on_changes with all watched files' do
      subject.should_receive(:run_on_changes).with(['a.sass', 'b.scss'])
      subject.run_all
    end
  end

  describe '#run_on_changes' do
    subject { Guard::Sass.new(watchers: [Guard::Watcher.new(/(.*)\.s[ac]ss/)]) }

    context 'if paths given contain partials' do
      it 'calls #run_all' do
        subject.should_receive(:run_all)
        subject.run_on_changes(['sass/_partial.sass'])
      end

      context "and :smart_partials is given" do
        before { subject.options[:smart_partials] = true  }
        after  { subject.options[:smart_partials] = false }

        it 'calls #resolve_to_owners' do
          paths = ['sass/_partial.sass']
          resolved_paths = ['a', 'b']

          subject
            .should_receive(:resolve_to_owners)
            .with(paths)
            .and_return(resolved_paths)

          subject
            .should_receive(:__run_paths)
            .with(resolved_paths)

          subject.run_on_changes(paths)
        end
      end
    end

    context 'when :always_resolve_dependencies is true' do
      before { subject.options[:always_resolve_dependencies] = true }
      after  { subject.options[:always_resolve_dependencies] = false }

      it 'compiles all changed and dependent files ' do
        paths = ['a', 'b']
        resolved_paths = ['c', 'd']

        subject
          .should_receive(:resolve_to_owners)
          .with(paths)
          .and_return(resolved_paths)

        subject
          .should_receive(:__run_paths)
          .with(resolved_paths + paths)

        subject.run_on_changes(paths)
      end
    end

    it 'starts the Runner' do
      runner.should_receive(:run).with(['a.sass']).and_return([nil, true])
      subject.run_on_changes(['a.sass'])
    end
  end

end
