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

def sign(reqstr, secretkey)
  CGI.escape(Base64.strict_encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, secretkey, reqstr.downcase.split(/&/).sort.join('&'))))
end

db = Mysql2::Client::new(:host => '172.16.1.2', :username => 'cloud', :password => 'cloud', :database => 'cloud')

user = nil
auth = nil
OptionParser.new do |opt|
  opt.on('-a VALUE') do |u|
    user = u
    puts "Will authenticate as user #{user}" if $DEBUG
    sql = "select uuid from user where username = '#{user}'"
    puts "Executing SQL query: #{sql}" if $DEBUG
    uid = ""
    db.query(sql).each do |col|
      uid = col['uuid']
    end
    uri = URI.parse("http://172.16.1.2:8096/client/api?command=registerUserKeys&id=#{uid}&response=json")
    p uri.request_uri if $DEBUG
    response = Net::HTTP.new(uri.host, uri.port).get(uri.request_uri)
    auth = JSON.parse(response.body)
    p auth if $DEBUG
  end
  opt.parse!(ARGV)
end

skip = false
while line = gets
  puts "Processing #{line}" if $DEBUG
  line.strip!
  if /^#/ =~ line
    case control = $'
    when /^exit/
      puts 'Exiting' if $DEBUG
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
  end

  next if skip

  cmd = line.split(/&/).shift
  puts "Using API: #{cmd}" if $DEBUG
  line.gsub!(/&([A-Za-z]+)=<([^&<>]+)>/) do |matched|
    puts "Substituting #{matched}" if $DEBUG
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
      when /account/i
        sql = "select uuid from account where name = '#{value}'"
      when /user/i
        sql = "select uuid from user where username = '#{value}'"
      when /zone/i
        sql = "select uuid from data_center where name = '#{value}'"
      when /physicalnetwork/i
        sql = "select uuid from physical_network where name = '#{value}'"
      when /networkserviceprovider/i
        val = value.split(/,/)
        sql = "select nsp.uuid from physical_network_service_providers nsp inner join physical_network pn on nsp.physical_network_id = pn.id and nsp.provider_name = '#{val[0]}' and pn.name = '#{val[1]}'"
      when /virtualrouterelement/i
        val = value.split(/,/)
        sql = "select v.uuid from virtual_router_providers v inner join physical_network_service_providers n on v.nsp_id = n.id and v.type = '#{val[0]}' inner join physical_network p on n.physical_network_id = p.id and p.name = '#{val[1]}'"
      end
    else
      sql = ' '
    end
    puts "Executing SQL query: #{sql}" if $DEBUG
    db.query(sql).each do |col|
      value = col['uuid']
    end
    '&' + param + '=' + value
  end

  if user
    reqstr = "command=#{line}&response=json&apikey=#{auth['registeruserkeysresponse']['userkeys']['apikey']}"
    reqstr.gsub!(/([^&=]+)=([^&=]+)/) do |matched|
      $1 + '=' + URI.encode($2)
    end
    signature = sign(reqstr, auth['registeruserkeysresponse']['userkeys']['secretkey'])
    uri = URI.parse("http://172.16.1.2:8080/client/api?#{reqstr}&signature=#{signature}")
  else
    uri = URI.parse("http://172.16.1.2:8096/client/api?command=#{line}&response=json")
  end
  p uri.request_uri
  unless $DEBUG
    response = Net::HTTP.new(uri.host, uri.port).get(uri.request_uri)
    jj JSON.parse(response.body)
  end
end
