#!/usr/bin/env ruby
$LOAD_PATH.unshift('./lib')
if Dir.exist? './vendor'
  $LOAD_PATH.unshift('./vendor/bundle/ruby/**gems/**/lib')
end

require 'faa_ois_api'
require 'pp'
pp FAAOISAPI::Page.parse
