module Termtter::Client
  register_hook(
    :name => :tco_saving,
    :point => :filter_for_output,
    :exec_proc => lambda do |statuses, event|
      statuses.each do |s|
        expand_tco_urls!(s.text, s.entities[:urls]) if s.entities
      end
      statuses
    end
  )

  def self.expand_tco_urls!(text, urls)
    urls.sort {|a, b| b[:indices][0] <=> a[:indices][0] }.each do |u|
      next unless u[:expanded_url]
      text[u[:indices][0]...u[:indices][1]] = u[:expanded_url]
    end
  end
end
