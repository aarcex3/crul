# # Import necessary modules
# require "http/server"
# require "uri"

# # Create a new HTTP server
# server = HTTP::Server.new do |context|
#   # Get the query parameters
#   query_params = URI.parse(context.request.resource).query_params

#   # Parse numbers from the query params and calculate the sum
#   sum = query_params.map do |_, value|
#     # Attempt to convert each parameter to an integer
#     value.to_i
#   end.sum

#   # Respond with the sum in JSON format
#   context.response.content_type = "application/json"
#   context.response.print("{\"sum\": #{sum}}")
# end

# # Bind the server to a local address and port
# address = "0.0.0.0"
# port = 8080
# server.bind_tcp(address, port)

# # Print a message indicating the server is running
# puts "Server is running on http://#{address}:#{port}"

# # Start the server
# server.listen

# Import necessary modules
require "http/client"
require "uri"
require "json"

# Let's assume @options has the necessary values for the request

# Assuming @host, @port, @options.headers, and @options.url are defined previously

# Initialize an HTTP client
client = HTTP::Client.new("httpbin.org")

# Create the HTTP request
request = HTTP::Request.new(
  method: "GET",
  resource: "https://httpbin.org/get?a=1&b=2", # The path part of the URL

)

# Execute the request and get the response
response = client.exec(request: request)

# Print the response (you can use pp for pretty-printing)
pp response

# If you'd like to print the status code and response body specifically:
puts "Status Code: #{response.status_code}"
puts "Response Body: #{response.body.to_s}"
