require 'resolv'

module Puppet::Parser::Functions
  newfunction(:lookupip, :type => :rvalue) do |args|
    Resolv::DNS::open {|r| ad=r.getaddresses(args[0]); r.close; (ad.collect {|a| a.to_s if a.kind_of?(Resolv::IPv4)} ).compact}.first || ''
  end
end
