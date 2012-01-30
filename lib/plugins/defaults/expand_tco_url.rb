module Termtter::Client
  register_hook(
    :name => :expand_tco_url,
    :point => :filter_for_output,
    :exec_proc => lambda do |statuses, event|
      statuses.each do |s|
        expand_tco_urls!(s.text, s.entities[:urls]) if s.entities
      end
      statuses
    end
  )

  def self.expand_tco_urls!(text, urls)
    urls.each do |u|
      next unless u[:expanded_url]
      text[/#{Regexp.escape(u[:url])}/] = u[:expanded_url]
    end
  end
end
