# coding: utf-8

require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'
require 'plugins/haml'

describe Termtter::Plugins::Haml do
  before do
    Termtter::API.stub!(:twitter).and_return(@twitter = mock(:twitter))
  end

  subject do
    @config = Termtter::Config.new
    @logger = mock(:logger)

    Termtter::Plugins::Haml.new(@config, @logger)
  end

  describe '#run' do
    context 'happy case' do
      before do
        @status = '<hamlified string>'
        subject.should_receive(:haml).with('xhtml').and_return(@status)
      end

      it 'update status with hamlified string' do
        @twitter.should_receive(:update).with(@status)
        subject.should_receive(:puts).with("=> #{@status}")

        subject.run('xhtml')
      end
    end

    context 'error occured in #haml' do
      before do
        subject.should_receive(:haml).and_raise(@error = StandardError.new)
      end

      it 'records the log' do
        @logger.should_receive(:error).with(@error)

        subject.run('xhtml')
      end
    end

    context '#haml returned nil' do
      before do
        subject.should_receive(:haml).and_return(nil)
      end

      it 'do nothing' do
        subject.run('xhtml')
      end
    end

    context '#haml returned empty string' do
      before do
        subject.should_receive(:haml).and_return('')
      end

      it 'do nothing' do
        subject.run('xhtml')
      end
    end
  end

  describe '#haml' do
    context 'neither argument nor options were specified' do
      before do
        # subject.should_receive(:editor).with(:haml).and_return('!!!')
      end

      it 'render Haml with default options' do
        pending("Not yet implemented")
        subject.haml('').should == <<-DTD.chomp
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
        DTD
      end
    end

    context 'argument was specified' do
      before do
        subject.should_receive(:editor).with(:haml).and_return('!!!')
      end

      it do
        subject.haml('html5').should == '<!DOCTYPE html>'
      end
    end

    context 'options was specified' do
      before do
        subject.should_receive(:editor).with(:haml).and_return('!!!')
      end

      it do
        @config.plugins.haml.options = {:format => :html5}
        subject.haml('').should == '<!DOCTYPE html>'
      end
    end

    context 'both argument and options were specified' do
      before do
        subject.should_receive(:editor).with(:haml).and_return('!!!')
      end

      it 'gives priority to argument' do
        @config.plugins.haml.options = {:format => :html5}

        subject.haml('xhtml').should == <<-DTD.chomp
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
        DTD
      end
    end

    context 'argument was invalid' do
      before do
        subject.should_receive(:editor).with(:haml).and_return('!!!')
      end

      it do
        expect { subject.haml('hoge') }.to raise_error
      end
    end

    context '#editor returned nil' do
      before do
        subject.should_receive(:editor).with(:haml).and_return(nil)
      end

      it do
        subject.haml('').should be_nil
      end
    end
  end
end
