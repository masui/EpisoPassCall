require 'webrick'

pwfile = "password.txt"
OPEN = "xdg-open"

unless File.exist?(pwfile) # パスワードが必要になったとき
  # ブラウザで /EpisoPassCall にアクセス                                                                                                                                                  
  system "#{OPEN} http://localhost:8000/EpisoPassCall"

  server = WEBrick::HTTPServer.new( # サーバを立てる                                                                                                                                                                                   
    :Port => 8000,
    :HTTPVersion => WEBrick::HTTPVersion.new('1.1'),
    :AccessLog => [[open(IO::NULL, 'w'), '']], # アクセスログを出力しない                                                                                                                                                              
    :Logger => WEBrick::Log.new("/dev/null")
  )
                                                                                                                                                                               
  # EpisoPass計算画面を開く
  # 計算後に/EpisoPassResultに移動                                                                                                                                                                         
  server.mount_proc('/EpisoPassCall') do |req, res|
    body = File.read('RunEpisoPass.html') # パスワード計算するHTML
    res.status = 200
    res['Content-Type'] = 'text/html'
    res.body = body
  end

  # /EpisoPassResult?qwerty のような形式でパスワードを返す                                                                                                                                                                            
  server.mount_proc('/EpisoPassResult') do |req, res|
    password = URI.decode(req.query_string)
    File.open(pwfile,"w"){ |f|
      f.puts password
    }
    server.shutdown
  end

  Signal.trap('INT'){server.shutdown}
  server.start
end

puts File.read(pwfile)

