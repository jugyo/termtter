module Termtter::Client
  add_filter do |statuses|
    statuses.each do |s|
      s.text.gsub!(%r'(http://tinyurl\.com(/[\w/]+))') do |m|
        expand_tinyurl($2) || $1
      end
    end
    statuses
  end
end

def expand_tinyurl(path)
  res = Net::HTTP.new('tinyurl.com').head(path)
  res['Location']
end
