require 'spec_helper'

describe Guard::Sass::Formatter do
  let(:hide_success) { false }
  subject { Guard::Sass::Formatter.new(hide_success: hide_success) }

  let(:notifier) { Guard::Notifier }
  let(:ui) { Guard::Compat::UI }

  describe '#success' do
    context 'if success is to be shown' do
      it 'shows a success message' do
        expect(ui).to receive(:info).with(
          "\t\e[1;37mSass\e[0m Success message", {}
        )
        subject.success('Success message')
      end

      it 'shows a system notification' do
        is_expected.to receive(:notify).with('Yay', image: :success)
        allow(ui).to receive(:info)
        subject.success('Success message', notification: 'Yay')
      end

      it 'shows a benchmark with time option' do
        time = 15
        expect(ui).to receive(:info).with(
          "\t\e[1;37mSass\e[0m [\e[33m#{time}.00s\e[0m] Success message", {}
        )
        subject.success('Success message', time: time)
      end
    end

    context 'if success is to be hidden' do
      let(:hide_success) { true }

      it 'does not show a message' do
        expect(ui).not_to receive(:info)
        subject.success('Success message')
      end
    end
  end

  describe '#error' do
    it 'shows an error message' do
      expect(ui).to receive(:error).with('[Sass] Error message', {})
      subject.error('Error message')
    end

    it 'shows a system notification' do
      is_expected.to receive(:notify).with('Boo', image: :failed)
      allow(ui).to receive(:error)
      subject.error('Error message', notification: 'Boo')
    end
  end

  describe '#notify' do
    it 'shows a system notification' do
      expect(notifier).to receive(:notify).with(
        'Notify message', title: 'Guard::Sass'
      )
      subject.notify('Notify message')
    end
  end
end
