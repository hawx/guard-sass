require 'spec_helper'

describe Guard::Sass do

  subject { ::Guard::Sass.new }

  let(:formatter) { Guard::Sass::Formatter.new }
  let(:runner) { Guard::Sass::Runner.new([], formatter) }

  before do
    subject.instance_variable_set :@runner, runner
    allow(runner).to receive(:run)
    allow(Guard).to receive(:listener).and_return('Listener')
  end

  describe '#initialize' do

    context 'when no options given' do
      it 'uses defaults' do
        expect(subject.options).to eq Guard::Sass::DEFAULTS
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
        expect(subject.options).to eq({
          :watchers     => [],
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
        })
      end
    end

    context 'with an :input option' do
      subject { Guard::Sass.new(watchers: [], input: 'app/styles') }

      it 'creates a watcher' do
        expect(subject.options[:watchers].size).to eq(1)
      end

      it 'watches all *.s[ac]ss files' do
        expect(subject.options[:watchers].first)
          .to eq Guard::Watcher.new(%r{^app/styles/(.+\.s[ac]ss)$})
      end

      context 'without an output option' do
        it 'sets the output directory to the input directory' do
          expect(subject.options[:output]).to eq 'app/styles'
        end
      end

      context 'with an output option' do
        subject do
          Guard::Sass.new(
            input: 'app/styles', output: 'public/styles', watchers: []
          )
        end

        it 'uses the output directory' do
          expect(subject.options[:output]).to eq 'public/styles'
        end
      end
    end

  end

  describe '#start' do
    it 'does not call #run_all' do
      expect(subject).not_to receive(:run_all)
      subject.start
    end

    context ':all_on_start option is true' do
      subject { Guard::Sass.new(watchers: [], all_on_start: true) }

      it 'calls #run_all' do
        expect(subject).to receive(:run_all)
        subject.start
      end
    end
  end

  describe '#run_all' do
    subject { Guard::Sass.new(watchers: [Guard::Watcher.new(/(.*)\.s[ac]ss/)]) }

    before do
      allow(Guard::Watcher).to receive(:match_files).and_return(
        ['a.sass', 'b.scss']
      )
    end

    it 'calls #run_on_changes with all watched files' do
      expect(subject).to receive(:run_on_changes).with(['a.sass', 'b.scss'])
      subject.run_all
    end
  end

  describe '#run_on_changes' do
    subject { Guard::Sass.new(watchers: [Guard::Watcher.new(/(.*)\.s[ac]ss/)]) }

    context 'if paths given contain partials' do
      it 'calls #run_all' do
        expect(subject).to receive(:run_all)
        subject.run_on_changes(['sass/_partial.sass'])
      end

      context "and :smart_partials is given" do
        before { subject.options[:smart_partials] = true  }
        after  { subject.options[:smart_partials] = false }
        it 'calls #resolve_partials_to_owners' do
          expect(subject).to receive(:resolve_partials_to_owners)
          subject.run_on_changes(['sass/_partial.sass'])
        end
      end
    end

    it 'starts the Runner' do
      expect(runner).to receive(:run).with(['a.sass']).and_return([nil, true])
      subject.run_on_changes(['a.sass'])
    end
  end

end
