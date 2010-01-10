config.plugins.draft.set_default(:ignore, [/^(reload\s+\-r|draft)/])

def list_drafts(drafts)
  drafts.each_with_index do |draft, index|
    puts "#{index}: #{draft}"
  end
end

def get_draft_index(arg)
  case arg
  when /^\d+$/
    arg.to_i
  when ''
    -1
  else
    nil
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
    index = get_draft_index(arg)
    if index
      command = public_storage[:drafts][index]
      if command
        puts "exec => \"#{command}\""
        execute(public_storage[:drafts][index])
        public_storage[:drafts].delete_at(index)
      end
    end
  end

  register_command('draft delete') do |arg|
    index = get_draft_index(arg)
    if index
      deleted = public_storage[:drafts].delete_at(index)
      puts "deleted => \"#{deleted}\"" if deleted
    end
  end

  register_command('draft clear') do |arg|
    public_storage[:drafts].clear
  end
end
