require 'sinatra/base'
require 'json'

# The practice of hard coding return values
# just to satisfy an expectation is known as sliming the test
# Sliming a test allow us to flesh out the spec end-to-end and then
# come back to implement the behavior properly

# Sliming (Fake it til you make it LOL) (Write it as simply as possible)
# Sliming a test helps with
# 1. Flow
#   - Helps achieve momentum for the person writing the test (gain traction speed to write test)
# 2. Test Coverage
#   - How much of your code is covered by your tests (Better edge cases) ~ gives confidence of customers
# 3. Reach Better Code
#   - (According to Robert C Martin (author of Clean code) could lead to better Algorithms!)

module ExpenseTracker
    class API < Sinatra::Base
        # mocks the response code supposedly that we get back from the app!
        post '/expenses' do 
            JSON.generate('expense_id' => 42)
        end

        get '/expenses/:date' do
            JSON.generate([])
        end
    end
end