require 'rubygems'
require 'sinatra/base'
require 'erb'
require 'yaml'


require 'json'
require "net/http"
require "uri"

require File.join(File.dirname(__FILE__), 'modules/config')
require File.join(File.dirname(__FILE__), 'modules/helpers')
require File.join(File.dirname(__FILE__), 'modules/mixins')

class NotesWebApp < Sinatra::Base
helpers NotesHelpers
helpers NotesConfig


get '/' do
  
  puts content_delivery_service_address
  topics = YAML::load_file('content/topics.yml')['topics']
  
  # convert to 2 D array 
  keys = topics.each_key.collect{|k|k}.sort
  #puts topics
  
  #puts keys
  grid_keys = []
  (0..keys.size-1).each do |index|
    if (index % 2 == 0)
      @row = []
      grid_keys.push @row
      @row[0] = keys[index]
    else
      @row[1] = keys[index]
    end
  end
  
  erb :index, :locals => {:grid_keys=> grid_keys , :topics => topics }
end

get '/home' do
  json = get_json2(content_delivery_service_address(), 'topics')
  topics = json.keys
  puts topics
  erb :home, :locals => {:topics => topics}
end

get "/wibble" do 
  json = get_json(content_delivery_service_address(), 'topics')
  
  json.keys.join(',')
  
  
end

get '/blibble' do
  markdown = <<-eos
Demo
====

This is a demo markdown page with syntax highlighting!

``` java
public class HelloThread extends Thread {
  	@Override
    public void run() {
      System.out.println("Hello from a thread!");
      }
    }
    
eos
    puts ENV.class
    puts request.public_methods
    html = post_to_url(markdown,"http://localhost:4403","/markdown/to/html")
    html
end  


get '/about' do 
  erb :about
end

get '/layout.css' do 
  sass :layout 
end

get '/notes/:topic/:category' do
  puts params
  content = load_content("content/#{params[:topic]}/#{params[:category]}.txt")
  if content.length > 0 
    erb :notes, :locals => { :content => content }
  else
    status 404
  end
end

get '/notes/:topic/:category/:note' do
  content = load_content("content/#{params[:topic]}/#{params[:category]}.txt")
  if content[params[:note].to_sym]
    erb :note, :locals => { :content => content[params[:note].to_sym] }
  else 
    status 404
  end
end

#see http://koffeinfrei.heroku.com/2012/03/24/sinatra-with-bourbon
get '/assets/css/:name.css' do |name|
  require './views/scss/bourbon/lib/bourbon.rb'
  content_type :css
  scss "scss/#{name}".to_sym, :layout => false
end


not_found do
  erb :notfound
end

end