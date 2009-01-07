plugin 'translation'

Termtter::Client.add_filter do |statuses|
  statuses.each do |s|
    if s.english?
      s.text = transelate(s.text, 'en|ja')
    end
  end
end
