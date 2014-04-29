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

proto = "http"
mgsvr = "172.16.1.2"
aport = "8096"
uport = "8080"
bpath = "/client/api"

def sign(reqstr, secretkey)
  CGI.escape(Base64.strict_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, secretkey, reqstr.downcase.split(/&/).sort.join('&'))))
end

db = Mysql2::Client::new(:host => "#{mgsvr}", :username => 'cloud', :password => 'cloud', :database => 'cloud')

user = ""
resp = nil
apikey = ""
secret = ""
OptionParser.new do |opt|
  opt.on('-a VALUE') do |u|
    user = u
    sql = "select uuid,api_key,secret_key from user where username = '#{user}'"
    uid = ""
    db.query(sql).each do |col|
      uid = col['uuid']
      apikey = col['api_key']
    end
    if apikey
      uri = URI.parse("#{proto}://#{mgsvr}:#{aport}#{bpath}?command=getUser&userApiKey=#{apikey}&response=json")
      resp = JSON.parse(Net::HTTP.new(uri.host, uri.port).get(uri.request_uri).body)
      secret = resp['getuserresponse']['user']['secretkey']
    else
      uri = URI.parse("#{proto}://#{mgsvr}:#{aport}#{bpath}?command=registerUserKeys&id=#{uid}&response=json")
      resp = JSON.parse(Net::HTTP.new(uri.host, uri.port).get(uri.request_uri).body)
      apikey = resp['registeruserkeysresponse']['userkeys']['apikey']
      secret = resp['registeruserkeysresponse']['userkeys']['secretkey']
    end
  end
  opt.parse!(ARGV)
end

skip = false
while line = gets
  line.strip!
  if /^#/ =~ line
    case control = $'
    when /^exit/
      puts 'Exiting'
      exit
    when /^skip/
      skip = true
    when /^start/
      skip = false
    when /^\d+/
      puts "Sleeping #{control} sec(s)"
      sleep control.to_i unless skip
    end
    next
  elsif /\\$/ =~ line
    line.slice!(-1)
    while cont = gets
      next if /^#/ =~ cont
      cont.strip!
      line << cont
      break unless /\\$/ =~ line
      line.slice!(-1)
    end
  end

  next if skip

  cmd = line.split(/&/).shift
  line.gsub!(/&([A-Za-z]+)=<([^&<>]+)>/) do |matched|
    value = $2
    case param = $1
    when /domainid/i
      sql = "select uuid from domain where name = '#{value}'"
    when /userid/i
      sql = "select uuid from user where username = '#{value}'"
    when /zoneid/i
      sql = "select uuid from data_center where name = '#{value}'"
    when /podid/i
      sql = "select uuid from host_pod_ref where name = '#{value}'"
    when /clusterid/i
      sql = "select uuid from cluster where name = '#{value}'"
    when /physicalnetworkid/i
      sql = "select uuid from physical_network where name = '#{value}'"
    when /id/i
      case cmd
      when /domain/i
        sql = "select uuid from domain where name = '#{value}'"
      when /account/i
        sql = "select uuid from account where name = '#{value}'"
      when /user/i
        sql = "select uuid from user where username = '#{value}'"
      when /zone/i
        sql = "select uuid from data_center where name = '#{value}'"
      when /physicalnetwork/i
        sql = "select uuid from physical_network where name = '#{value}'"
      when /networkoffering/i
        sql = "select uuid from network_offerings where name = '#{value}'"
      when /networkserviceprovider/i
        val = value.split(/,/)
        sql = "select nsp.uuid from physical_network_service_providers nsp inner join physical_network pn on nsp.physical_network_id = pn.id and nsp.provider_name = '#{val[0]}' and pn.name = '#{val[1]}'"
      when /(virtualrouter|internalloadbalancer)element/i
        val = value.split(/,/)
        sql = "select v.uuid from virtual_router_providers v inner join physical_network_service_providers n on v.nsp_id = n.id and v.type = '#{val[0]}' inner join physical_network p on n.physical_network_id = p.id and p.name = '#{val[1]}'"
      end
    else
      sql = ' '
    end
    db.query(sql).each do |col|
      value = col['uuid']
    end
    '&' + param + '=' + value
  end

  if user.empty?
    uri = URI.parse("#{proto}://#{mgsvr}:#{aport}#{bpath}?command=#{line}&response=json")
  else
    reqstr = "command=#{line}&response=json&apikey=#{apikey}"
    reqstr.gsub!(/([^&=]+)=([^&=]+)/) do |matched|
      $1 + '=' + URI.encode($2)
    end
    signature = sign(reqstr, secret)
    uri = URI.parse("#{proto}://#{mgsvr}:#{uport}#{bpath}?#{reqstr}&signature=#{signature}")
  end
  p uri.to_s
  http = Net::HTTP.new(uri.host, uri.port)
  http.read_timeout = 180
  jj JSON.parse(http.get(uri.request_uri).body)
end
