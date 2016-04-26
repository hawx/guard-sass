require 'spec_helper'

describe Guard::Sass::Formatter do

  subject { Guard::Sass::Formatter }

  let(:notifier) { Guard::Notifier }

  let(:ui) {
    ::Guard::UI.stub(:error)
    ::Guard::UI.stub(:info)

    ::Guard::UI
  }

  describe '#success' do
    context 'if success is to be shown' do
      it 'shows a success message' do
        ui.should_receive(:info).with("\t\e[1;37mSass\e[0m Success message", {})
        subject.new.success("Success message")
      end

      it 'shows a system notification' do
        ui.should_receive(:info).with("\t\e[1;37mSass\e[0m Success message", notification: 'Yay')
        notifier.should_receive(:notify).with('Yay', title: 'Guard::Sass', image: :success)
        subject.new.success("Success message", notification: "Yay")
      end
    end

    context 'if success is to be hidden' do
      it 'does not show a message' do
        ui.should_not_receive(:info)
        subject.new(:hide_success => true).success("Success message")
      end
    end
  end

  describe '#error' do
    it 'shows an error message' do
      ui.should_receive(:error).with("[Sass] Error message", {})
      subject.new.error("Error message")
    end

    it 'shows a system notification' do
      ui.should_receive(:error).with('[Sass] Error message', notification: 'Boo')
      notifier.should_receive(:notify).with('Boo', title: 'Guard::Sass', image: :failed)
      subject.new.error("Error message", notification: "Boo")
    end
  end

  describe '#notify' do
    it 'shows a system notification' do
      notifier.should_receive(:notify).with('Notify message', :title => 'Guard::Sass')
      subject.new.notify('Notify message')
    end
  end

end
