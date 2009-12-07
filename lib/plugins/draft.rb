config.plugins.draft.set_default(:ignore, [/^(reload\s+\-r|draft)/])

def list_drafts(drafts)
  drafts.each_with_index do |draft, index|
    puts "#{index}: #{draft}"
  end
end

module Termtter::Client
  public_storage[:drafts] ||= []

  register_hook(:save_as_draft, :point => :timeout) do |input_text|
    if !config.plugins.draft.ignore.any? {|pattern| pattern =~ input_text} &&
        public_storage[:drafts].last != input_text
      public_storage[:drafts] << input_text
      puts "Save as draft: #{input_text}"
    end
  end

  register_command('draft list') do |arg|
    list_drafts(public_storage[:drafts])
  end

  register_command('draft exec') do |arg|
    case arg
    when /^\d+$/
      index = arg.to_i
    when ''
      index = -1
    end
    command = public_storage[:drafts][index]
    if command
      puts "exec => \"#{command}\""
      call_commands(public_storage[:drafts][index])
      public_storage[:drafts].delete_at(index)
    end
  end

  register_command('draft delete') do |arg|
    case arg
    when /^\d+$/
      index = arg.to_i
    when ''
      index = -1
    end
    deleted = public_storage[:drafts].delete_at(index)
    puts "deleted => \"#{deleted}\"" if deleted
  end

  register_command('draft clear') do |arg|
    public_storage[:drafts].clear
  end
end
