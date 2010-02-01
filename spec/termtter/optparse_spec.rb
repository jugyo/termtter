# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

module Termtter
  describe OptParser do

    before do
      @original_conf ||= config
    end

    after do
      conf = @original_conf
    end

    def run_termtter(opt)
      `./bin/termtter #{opt}`
    end

    it 'accepts -h option' do
      run_termtter('-h').should match(/Usage/)
    end

    it 'accepts -f option' do
      Termtter::OptParser::parse!(%w{-f ~/config})
      Termtter::CONF_FILE.should == '~/config'
    end

    it 'accepts -t option' do
      Termtter::OptParser::parse!(%w{-t ~/termtter_directory})
      Termtter::CONF_DIR.should == '~/termtter_directory'
    end

    it 'accepts -d option' do
      Termtter::OptParser::parse!(%w{-d})
      config.devel.should be_true
    end

    it 'accepts -c option' do
      Termtter::OptParser::parse!(%w{-c})
      config.system.cmd_mode.should be_true
    end

    it 'accepts -r option' do
      Termtter::OptParser::parse!(%w{-r cool})
      config.system.run_commands.should == %w{cool}
    end

    it 'accepts -p option' do
      Termtter::OptParser::parse!(%w{-p cool})
      config.system.load_plugins.should == %w{cool}
    end

    it 'accepts -e option' do
      Termtter::OptParser::parse!(%w{-e foo})
      config.system.eval_scripts.should == %w{foo}
    end

    it 'accepts -m option' do
      require 'termcolor'
      TermColor.parse('<red>cool</red>').should == "\e[31mcool\e[0m"
      Termtter::OptParser::parse!(%w{-m})
      TermColor.parse('<red>cool</red>').should == 'cool'
      module ::TermColor
        class << self
          alias parse parse_orig
        end
      end
    end

  end
end
