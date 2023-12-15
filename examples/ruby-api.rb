# load the gem file for descope locally

require 'descope'

c = Descope::Client.new({project_id: "P2OZcvKK1XtbyIlgYpdeqbRbtWwb", management_key: ENV['MGMT_KEY']})

d = c.load(nil, "U2XuO2LSj1DGaUSnSgTWIEiWQIO8")
# d = c.mgmt.user.load(nil, "U2XuO2LSj1DGaUSnSgTWIEiWQIO8")
puts d["user"]["loginIds"]