# load the gem file for descope locally

require 'descope'

c = Descope::Client.new({project_id: "P2OZcvKK1XtbyIlgYpdeqbRbtWwb", management_key: ENV['MGMT_KEY']})

d = c.load(user_id: "U2XuO2LSj1DGaUSnSgTWIEiWQIO8")
puts d