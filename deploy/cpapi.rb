#!/usr/bin/env ruby

require 'optparse'
require 'rubygems'
require 'mysql2'
require 'json'
require 'net/http'
require 'uri'
require 'cgi'
require 'openssl'
require 'base64'

def sign(restpath, params, secret)
  puts "IN(sign):" if $DEBUG
  p restpath if $DEBUG
  p params if $DEBUG
  p secret if $DEBUG
  sorted = restpath + params.split(/&/).map{|x| x.downcase}.sort.join('&')
  p sorted if $DEBUG
  puts "OUT(sign):" if $DEBUG
  CGI.escape(Base64.strict_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, secret, sorted)))
end

puts "Main:" if $DEBUG

directions = "accounts"

=begin
db = Mysql2::Client::new(:host => '172.16.1.3', :username => 'cloud', :password => 'cloud', :database => 'cloud_portal')
while line = gets
  resource = line.split(/\//).shift
  puts "Resource: #{resource}" if $DEBUG
  line.gsub!(/&([A-Za-z]+)=<([^&<>]+)>/) do |matched|
    puts "Substituting #{matched}" if $DEBUG
    rvalue = $2
    value = CGI.unescape(rvalue)
    case param = $1
    when /domainid/i
      sql = "select uuid from domain where name = '#{value}'"
    else
      sql = ' '
    end
    puts "Executing SQL query: #{sql}" if $DEBUG
    db.query(sql).each do |col|
      value = col['uuid']
    end
    '&' + param + '=' + value
  end
=end

restpath = "/" + directions
p restpath if $DEBUG
params = "_=" + (Time.now.to_i * 1000).to_s + "&apiKey=LWvQjAhyPUhmxmpuoskUOWwN_8zG-CjgLKI30J0bFSX7zzAkSBZjsczTk250GlE7F_qG9zfVT-GzPzV8RrdE7A"
params.gsub!(/([^&=]+)=([^&=]+)/) do |matched|
  $1 + '=' + URI.encode_www_form_component($2)
end
p params if $DEBUG
secret = "02XQpBFOfNqpFCcCWId9W2Q2CaEQWwekrmq9nWSmyeEStJUUuezFE0NbOTeExiIv1eRarvdygziINPeCfPfaOQ"
signature = sign(restpath, params, secret)
p signature if $DEBUG
uri = URI.parse("http://172.16.1.3:8080/portal/api#{restpath}?#{params}&signature=#{signature}")
p uri.request_uri
unless $DEBUG
  response = Net::HTTP.new(uri.host, uri.port).get(uri.request_uri)
  result = JSON.parse(response.body)
  jj result
end
