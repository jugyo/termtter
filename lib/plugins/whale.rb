# -*- coding: utf-8 -*-
module Termtter
  class RubytterProxy
    alias_method :error_html_message_orig, :error_html_message

    def error_html_message_whale(e)
      if %r'Twitter / Over capacity' =~ e.message
        WHALE
      else
        error_html_message_orig(e)
      end
    end

    alias_method :error_html_message, :error_html_message_whale
  end

  # first blank line is to skip prompt.
  WHALE = <<'__WHALE__'

　 ,......-..-—‐—--..r､_　　　,r:,         Twitter / Over capacity
　ヾー-ﾟ､ :::::::::::::::::::::::::_￣ﾆ､く
　　 ﾞ`ー-`ｰ'-ー'"￣　　　　`'
__WHALE__
end

# whale.rb:
#   print whale when twitter is over capacity.
#   ASCII-Art from http://bhdaamov.hp.infoseek.co.jp/zukan/fish.html#kuji
