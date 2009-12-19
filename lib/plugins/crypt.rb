# -*- coding: utf-8 -*-

require 'openssl'

config.plugins.crypt.set_default(:salt, 'No Termtter, No Life.')

def encrypt(msg, salt)
  encoder = OpenSSL::Cipher::DES.new
  encoder.encrypt
  encoder.pkcs5_keyivgen(salt)
  (encoder.update(msg) + encoder.final).unpack('H*').to_s
end

def decrypt(msg, salt)
  decoder = OpenSSL::Cipher::DES.new
  decoder.decrypt
  decoder.pkcs5_keyivgen(salt)
  decoder.update([msg].pack('H*')) + decoder.final
end

Termtter::Client.register_command(
  :name => :crypt,
  :help => ['crypt TEXT', 'Post a encrypted message'],
  :exec_proc => lambda {|arg|
    msg = arg
    prefix = '{DES}'
    status = prefix + encrypt(msg, config.plugins.crypt.salt)
    Termtter::API.twitter.update(status)
    puts "=> #{status}"
    status
  }
  )

Termtter::Client::register_hook(
  :name => :decrypt_message,
  :point => :filter_for_output,
  :exec_proc => lambda do |statuses, event|
    statuses.each do |s|
      s.text.gsub!(/^\{DES\}(.*)/) do |m|
        "{decrypt}" + decrypt($1, config.plugins.crypt.salt)
      end
    end
  end
)
