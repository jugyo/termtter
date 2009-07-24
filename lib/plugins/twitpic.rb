# = twitpic
#
# == usage
#  > twitpic [MESSAGE] [IMAGE_FILE]
#
# == requirements
# * twitpic
#  sudo gem install twitpic
#
# == TODO
# * スペースの混じったファイル名を扱えるようにする

gem "twitpic", ">=0.3.1"
require 'twitpic'

module Termtter::Client
  register_command(
    :name => :twitpic,
    :help => ['twitpic [MESSAGE] [IMAGE_FILE]', 'Upload a image file to TwitPic'],
    :exec => lambda do |arg|
      path = arg.scan(/[^\s]+$/).flatten.first rescue nil

      if path && File.exists?(path) && File.file?(path)
        text = arg.gsub(/[^\s]+$/, '').strip
      else
        path = Termtter::CONF_DIR + '/tmp/twitpic_screencapture.png'
        File.delete(path) if File.exists?(path)
        puts 'Please capture screen!'
        system('screencapture', '-i', '-f', path) || system('import', path) # TODO: こんなんで大丈夫かな
        text = arg
      end

      if File.exists?(path)
        puts 'Uploading...'
        url = TwitPic.new(config.user_name, config.password).upload(path)[:mediaurl]
        puts "  => \"#{url}\""
        post_message = "#{text} #{url}".strip
        puts 'Post a message...'
        Termtter::API.twitter.update(post_message)
        puts "  => \"#{post_message}\""
      else
        puts 'Aboat!'
      end
    end
  )
end
