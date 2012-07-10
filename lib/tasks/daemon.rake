## This rakefile starts/stops the mongrel server as a daemon 

require 'rubygems'
require 'daemons'

namespace "server" do

  task :start => [:environment] do
    #system "ruby #{Rails.root}/lib/daemon/server start"
    system "ruby script/server -p 80 -d"
    puts "Server started on port 80...."
  end

  task :stop => [:environment] do
    system "ruby #{Rails.root}/lib/daemon/server stop"
    puts "Server stopped...."
  end

end

namespace "construction" do

  task :start => [:environment] do
    system "ruby #{Rails.root}/lib/daemon/construction start" 
    puts "Construction page has been started on port 80" 
  end

  task :stop => [:environment] do
    system "ruby #{Rails.root}/lib/daemon/construction stop"
    puts "Construction page has been stopped"  
  end

end
