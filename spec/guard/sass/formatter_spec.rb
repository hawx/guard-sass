require 'spec_helper'

describe Guard::Sass::Formatter do

  subject { Guard::Sass::Formatter }

  let(:notifier) { Guard::Notifier }
  let(:ui) { Guard::Compat::UI }

  describe '#success' do
    context 'if success is to be shown' do
      it 'shows a success message' do
        expect(ui).to receive(:info).with(
          "\t\e[1;37mSass\e[0m Success message", {}
        )
        subject.new.success("Success message")
      end

      it 'shows a system notification' do
        f = subject.new
        expect(f).to receive(:notify).with("Yay", :image => :success)
        f.success("Success message", :notification => "Yay")
      end
    end

    context 'if success is to be hidden' do
      it 'does not show a message' do
        expect(ui).not_to receive(:info)
        subject.new(:hide_success => true).success("Success message")
      end
    end
  end

  describe '#error' do
    it 'shows an error message' do
      expect(ui).to receive(:error).with("[Sass] Error message", {})
      subject.new.error("Error message")
    end

    it 'shows a system notification' do
      f = subject.new
      expect(f).to receive(:notify).with("Boo", :image => :failed)
      f.error("Error message", :notification => "Boo")
    end
  end

  describe '#notify' do
    it 'shows a system notification' do
      expect(notifier).to receive(:notify).with(
        'Notify message', :title => 'Guard::Sass'
      )
      subject.new.notify('Notify message')
    end
  end

end