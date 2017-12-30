json.extract! server, :id, :name, :public_ip, :created_at, :updated_at
json.url server_url(server, format: :json)
