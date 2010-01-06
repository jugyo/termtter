# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../../spec_helper'

describe 'Termtter::Client.post_retweet' do
  describe 'posts a retweet based on the given post by someone,' do
    describe 'with your own comment,' do
      it 'and without confirming in the original post being not protected' do
        Termtter::Client.plug 'defaults/retweet'

        mock = Object.new
        def mock.user
          mock2 = Object.new
          def mock2.protected
            false
          end

          def mock2.screen_name
            'ujihisa'
          end
          mock2
        end

        def mock.text
          'hi'
        end

        mock3 = Object.new
        def mock3.update(text)
          text.should == 'my comment RT @ujihisa: hi'
        end

        Termtter::API.should_receive(:twitter).and_return(mock3)
        be_quiet do
          Termtter::Client.post_retweet(mock, 'my comment')
        end
      end

      it 'and with confirming in the original post being protected' do
        Termtter::Client.plug 'defaults/retweet'

        mock = Object.new
        def mock.user
          mock2 = Object.new
          def mock2.protected
            true
          end

          def mock2.screen_name
            'ujihisa'
          end
          mock2
        end

        def mock.text
          'hi'
        end

        mock3 = Object.new
        def mock3.update(text)
          text.should == 'my comment RT @ujihisa: hi'
        end
        def mock3.retweet(id)
          id
        end

        Termtter::API.should_receive(:twitter).and_return(mock3)
        Termtter::Client.
          should_receive(:confirm).
          with('ujihisa is protected! Are you sure?', false).
          and_return true
        be_quiet do
          Termtter::Client.post_retweet(mock, 'my comment')
        end
      end
    end
  end
end

describe 'Plugin `retweet`' do
  it 'registers a commond when it is loaded' do
    Termtter::Client.should_receive(:register_command).at_least(5).times
    Termtter::Client.plug 'defaults/retweet'
  end
end
