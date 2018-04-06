require_relative '../../../app/api'
require 'rack/test'

# Note: The seam betweeen layers is where integration bugs hide
# Unit tests lie here (because its testing the API's functionality here)
module ExpenseTracker
    RSpec.describe API do
        include Rack::Test::Methods # mixin
        
        def app
            API.new(ledger: ledger)
        end

        # instance_double allows us to mock an object we haven't implemented yet (i feel like this is a waste of time imo)
        let(:ledger) { instance_double('ExpenseTracker::Ledger') }

        describe 'POST /expenses' do
            context 'when the expense is successfully recorded' do
                let(:expense) { { 'some' => 'data'} }

                # before hook - is included in the scope of each it block when the test cases are run
                # each test case gets its own copy of the variables assigned here
                # these examples use DRY (Don't Repeat Yourself Principle)
                before do
                    # calling allow from rspec-mocks
                    # allow configures the test double's behavior
                    # when the caller (API class) invokes the record, the double will return a new RecordResult instance
                    # indicating a successful posting
                    allow(ledger).to receive(:record)
                    .with(expense)
                    .and_return(RecordResult.new(true, 417, nil))
                end

                it 'returns the expense id' do
                    post '/expenses', JSON.generate(expense)

                    parsed = JSON.parse(last_response.body)
                    expect(parsed).to include('expense_id' => 417)
                end

                it 'responds with a 200 (OK)' do
                    post '/expenses', JSON.generate(expense)
                    expect(last_response.status).to eq(200)
                end
            end
            
            context 'when the expense fails validation' do
                let(:expense) { { 'some' => 'data' } }
                
                before do
                    allow(ledger).to receive(:record)
                    .with(expense)
                    .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
                end

                it 'returns an error message' do
                    post '/expenses', JSON.generate(expense)

                    parsed = JSON.parse(last_response.body)
                    expect(parsed).to include('error' => 'Expense incomplete')
                end

                it 'responds with a 422 (Unprocessable entity)' do
                    post '/expenses', JSON.generate(expense)
                    expect(last_response.status).to eq(422)
                end
            end
        end
    end
end