require 'sinatra/base'
require 'json'

require_relative 'ledger'

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


# JSON.generate(hash_object) returns a JSON string
# JSON.parse(json_string) returns a json hash object

module ExpenseTracker
    class API < Sinatra::Base
        def initialize(ledger: Ledger.new)
            @ledger = ledger
            super() # rest of initialization from Sinatra
        end
        
        # mocks the response code supposedly that we get back from the app!
        # In Sinatra, the following methods below are called routes!
        post '/expenses' do 
            # status 404 # test for failure
            expense = JSON.parse(request.body.read)
            result = @ledger.record(expense)

            if result.success?
                JSON.generate('expense_id' => result.expense_id)
            else
                status 422
                JSON.generate('error' => 'Expense incomplete')
            end
        end

        get '/expenses/:date' do
            JSON.generate([])
        end
    end
end