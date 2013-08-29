require 'rubygems'
require 'sinatra'

set :sessions, true

get '/hello' do
  "Hello to you kind sir!"
end

get '/template' do
  erb :template_test
end

get '/nested' do
  erb :"users/nested"
end


