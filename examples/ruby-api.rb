require 'descope'

dev_project_id = 'P2ZoKhzAdvZV9HzRZ0SE8pIdNq8P'
client = Descope::Client.new(
  {
    descope_api_url: "api.descope.dev",
    project_id: dev_project_id,
    management_key: ENV['MGMT_KEY']
  }
)

puts "client: #{client.inspect}"

# Create user
def create_user(client)
  user_create_res = client.create_user(
    login_id: "ami_ruby_sdk+ami@descope.com",
    # email: "ami_ruby_sdk+ami@descope.com",
    # phone: "3474500361",
    # display_name: "Ami Ruby SDK",
    # user_tenants: [
    #   {
    #     tenant_id: "T2ZoKhzAdvZV9HzRZ0SE8pIdNq8P",
    #     role_names: ["RubySdkAdmin"]
    #   }
    # ],
    # picture: 'https://static-00.iconduck.com/assets.00/ruby-gems-icon-447x512-6feckqly.png',
    # family_name: "Ruby",
    # given_name: "SDK",
    # custom_attributes: {
    #   "custom_attribute_1" => "custom_value_1",
    #   "custom_attribute_2" => "custom_value_2"
    # },
    )

  puts "user_create_res: #{user_create_res}"
end

def load_user(client)
  user_load_res = client.load_user(login_id: "stam@nowhere.com")
  # user_load_res = client.load_by_user_id(user_id: "U2ZpARjKAJJmq0fzU2lXNNCGnF4j")
  puts "user_load_res: #{user_load_res}"
end

load_user(client)