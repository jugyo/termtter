require File.expand_path(File.dirname(__FILE__)) + '/../spec_helper'

describe Termtter::Client, 'when the plugin hi is loaded' do
  it 'adds commands such as hi and hola' do
    Termtter::Client.should_receive(:register_command).at_most(9).times
    Termtter::Client.plug 'hi'
  end
end

