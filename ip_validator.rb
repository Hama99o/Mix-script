require 'ipaddr'
def ip_validator(ip)
  !(IPAddr.new(ip) rescue nil).nil?
end
