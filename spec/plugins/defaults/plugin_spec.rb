require File.dirname(__FILE__) + '/../../spec_helper'

describe 'plugin hashtag' do
  before do
    Termtter::Client.clear_hooks
    Termtter::Client.setup_task_manager
    Termtter::Client.plug 'defaults'
  end

  it 'should search plugin file' do
    Termtter::Client.search_plugin_file('plugin').should ==
      File.expand_path(File.join(File.dirname(__FILE__), '../../..//lib/plugins/defaults/plugin.rb'))
  end

  # TODO: more specs...
end

