require_relative '../../app/api'
require 'rack/test'
require 'json'

# 1st step is to write code you wish you had to help flesh out the design of the code

module ExpenseTracker
    RSpec.describe 'Expense Tracker API' do
        include Rack::Test::Methods
        
        # when requiring rack/test as a dependency for a file such as this
        # you must define an app method (https://github.com/rack-test/rack-test#examples)
        def app
            ExpenseTracker::API.new # Assume class we make is called API
        end

        def post_expense(expense)
            post '/expenses', JSON.generate(expense)
            expect(last_response.status).to eq(200)

            parsed = JSON.parse(last_response.body)
            expect(parsed).to include('expense_id' => a_kind_of(Integer)) # composing matchers example
            return expense.merge('id' => parsed['expense_id']) # returns a hash of expense data
        end

        it 'records submitted expenses' do
            pending 'Need to persist expenses'
            
            # symbol key value hash
            # coffee = {
            #   payee: 'Starbucks'    
            #}

            # key=string value hash
            coffee = post_expense(
                'payee' => 'Starbucks',
                'amount' => 5.75,
                'date' => '2017-06-10'
            )

            zoo = post_expense(
                'payee' => 'Zoo',
                'amount' => 15.25,
                'date' => '2017-06-10'
            )

            groceries = post_expense(
                'payee' => 'Whole Foods',
                'amount' => 95.20,
                'date' => '2017-06-11'
            )

            get '/expenses/2017-06-10'
            # Grabs response from Rack::Test
            expect(last_response.status).to eq(200)

            expenses = JSON.parse(last_response.body)
            expect(expenses).to contain_exactly(coffee, zoo)
        end
    end
end
