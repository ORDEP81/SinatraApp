require 'rubygems'
require 'sinatra'

set :sessions, true

get '/hello' do
  "Hello to you kind sir!"
end


