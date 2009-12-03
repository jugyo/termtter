require 'net/http'

def post_gyazo
  browser_cmd = 'firefox'
  gyazo_url = ""
  
  idfile = ENV['HOME'] + "/.gyazo.id"
  
  id = ''
  if File.exist?(idfile) then
    id = File.read(idfile).chomp
  else
    id = Time.new.strftime("%Y%m%d%H%M%S")
    File.open(idfile,"w").print(id+"\n")
  end
  
  tmpfile = "/tmp/image_upload#{$$}.png"
  
  system "import #{tmpfile}"
  
  imagedata = File.read(tmpfile)
  File.delete(tmpfile)
  
  boundary = '----BOUNDARYBOUNDARY----'
  
  data = <<EOF
--#{boundary}\r
content-disposition: form-data; name="id"\r
\r
#{id}\r
--#{boundary}\r
content-disposition: form-data; name="imagedata"\r
\r
#{imagedata}\r
\r
--#{boundary}--\r
EOF

  header ={
    'Content-Length' => data.length.to_s,
    'Content-type' => "multipart/form-data; boundary=#{boundary}"
  }

  Net::HTTP.start("gyazo.com",80){|http|
    res = http.post("/upload.cgi",data,header)
    url = res.response.to_ary[1]
    puts url
    system "#{browser_cmd} #{url}"
    gyazo_url = url
  }
  return gyazo_url
end

Termtter::Client.register_command(
  :name => :gyazo,
  :help => ['gyazo comment', 'upload a captured image'],
  :exec => lambda {|arg|
    text = arg
    url = post_gyazo
    Termtter::API.twitter.update(text + " " + url)
    puts "=> " << text + " " + url
  }
)

# gyazo:
#   Capture an arbitary desktop area and upload the image to gyazo.com, 
#   open it up with the browser you specified. Then, tweet the link with
#   a message. 
# 
#   You need ImageMagick tools and a web browser(default:Firefox, as you
#   can see.)
#
# thanks to:
#   http://yaa.no-ip.org/~yaa/diary/20071108.html#p04
#
# example:
#   gyazo What a lame dialogue message! (capture process starts...)
#
