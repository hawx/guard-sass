require 'spec_helper'

describe Guard::Sass::Formatter do

  subject { Guard::Sass::Formatter }

  let(:notifier) { Guard::Notifier }
  let(:ui) { Guard::UI }
  
  describe '#success' do
    context 'if success is to be shown' do
      it 'shows a success message' do
        ui.should_receive(:info).with("Success message", {})
        subject.new.success("Success message")
      end
      
      it 'shows a system notification' do
        f = subject.new
        f.should_receive(:notify).with("Yay", :image => :success)
        f.success("Success message", :notification => "Yay")
      end
    end
    
    context 'if success if to be hidden' do
      it 'does not show a message' do
        ui.should_not_receive(:info)
        subject.new(:show_success => false).success("Success message")
      end
    end
  end
  
  describe '#error' do
    it 'shows an error message' do
      ui.should_receive(:error).with("Error message", {})
      subject.new.error("Error message")
    end
    
    it 'shows a system notification' do
      f = subject.new
      f.should_receive(:notify).with("Boo", :image => :failed)
      f.error("Error message", :notification => "Boo")
    end
  end
  
  describe '#notify' do
    context 'if notification has been set to true' do
      it 'shows a system notification' do
        notifier.should_receive(:notify).with('Notify message', :title => 'Guard::Sass')
        subject.new.notify('Notify message')
      end
    end
    
    context 'if notification has been set to false' do
      it 'does not shows a notification' do
        notifier.should_not_receive(:notify)
        subject.new(:notification => false).notify('Notify message')
      end
    end
  end 
  
end