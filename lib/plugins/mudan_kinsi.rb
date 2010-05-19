# coding: utf-8
# http://twitter.com/ototorosama/status/14283311303

Termtter::Client.register_hook(
  :name => :mudan_kinsi,
  :point => :pre_coloring,
  :exec => lambda {|r,e|
    r.gsub(/無断(.+)禁止/) {|s|
      "か、勝手に#{$1}しないでよね!! ...バカ....."
    }
  }
)
