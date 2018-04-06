# hooks application up to a web server to see it actually working
# type in 'bundle exec rackup' to see the application run in action

# to see a response the server generates to the client use curl command
# curl localhost:9292/expenses/2017-06-10 -w "\n"

require_relative 'app/api'
run ExpenseTracker::API.new
