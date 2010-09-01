# -*- coding: utf-8 -*-
module Termtter::Client
  config.plugins.encoding.set_default(:output, 'utf-8')

  def self.encode text, encoding
    return text unless encoding

    if RUBY_VERSION >= '1.9'
      begin
        text = text.encode encoding
      rescue
        # no encodings exception
      end
    else
      begin 
        require 'nkf'
      rescue
        return text
      end

      text = case encoding
             when 'utf-8'
               NKF.nkf('-w', text)
             when 'euc-jp'
               NKF.nkf('-e', text)
             when 'sjis'
               NKF.nkf('-s', text)
             else
               text
             end
    end
  end

  register_hook(
                :name => :output_encoding,
                :points => [:pre_output],
                :exec_proc => lambda {|result, event|
                  result = Termtter::Client.encode result, config.plugins.encoding.output
                })
  register_hook(
                :name => :input_encoding,
                :point => /^modify_arg_for_.*/,
                :exec_proc => lambda {|cmd, arg|
                  arg = Termtter::Client.encode arg, 'utf-8'
                })
end
