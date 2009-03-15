# -*- coding: utf-8 -*-

plugin 'translation'

Termtter::Client.add_filter do |statuses, event|
  statuses.each do |s|
    if s.english?
      s.text = translate(s.text, 'en|ja')
    end
  end
end
