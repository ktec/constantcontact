require 'rubygems'
require 'bundler'
Bundler.setup

require File.join(File.dirname(__FILE__), '/../lib/constantcontact')
require 'constantcontact/searchable_behavior'
include ConstantContact

def set_default_credentials
  Base.api_key = ENV['CONSTANTCONTACT_KEY'] || 'api_key'
  Base.user = ENV['CONSTANTCONTACT_USER'] || 'joesflowers'
  Base.password = ENV['CONSTANTCONTACT_PASSWORD'] || 'password'
end

require 'fakeweb'
FakeWeb.allow_net_connect = false
def fixture_file(filename)
  return '' if filename.blank?
  file_path = File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
  File.read(file_path)
end
def constant_contact_url(url)
  url =~ /^http/ ? url : "https://api_key%25joesflowers:password@api.constantcontact.com/ws/customers/joesflowers#{url}"
end
def stub_get(url, filename, status=nil)
  options = {:body => fixture_file(filename)}
  options.merge!({:status => status}) unless status.nil?
  
  FakeWeb.register_uri(:get, constant_contact_url(url), options)
end
def stub_post(url, filename)
  FakeWeb.register_uri(:post, constant_contact_url(url), :body => fixture_file(filename))
end
def stub_put(url, filename)
  FakeWeb.register_uri(:put, constant_contact_url(url), :body => fixture_file(filename))
end
def stub_delete(url, status)
  options = {:status => status}
  FakeWeb.register_uri(:delete, constant_contact_url(url), options)
end

