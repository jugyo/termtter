plugin 'translation'

Termtter::Client.add_filter do |statuses|
  statuses.each do |s|
    if Termtter::Status.english?(s.text)
      s.text = transelate(s.text, 'en|ja')
    end
  end
end
