# -*- coding: utf-8 -*-

module Termtter::Client
  register_macro(:otsune, "update %s 頭蓋骨の中身がお気の毒です.",
    :help => ['otsune {SCREENNAME}', 'update "@{SCREENNAME} 頭蓋骨の中身がお気の毒です"']
  )
end

module Termtter::Client
  register_macro(:otsnue, "update @%s 頭蓋骨の中身がお気の毒です.",
    :help => ['otsnue {SCREENNAME}', 'update @%s 頭が気の毒です.']
  )
end

# vim: fenc=utf8
