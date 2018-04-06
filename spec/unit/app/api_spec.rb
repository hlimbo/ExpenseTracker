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

        # find a way to reducee the duplicated logic of returned the parsed json object from the last_response from Rack::Test
        def last_response_body
            JSON.parse(last_response.body)
        end

        # instance_double allows us to mock an object we haven't implemented yet (i feel like this is a waste of time imo)
        let(:ledger) { instance_double('ExpenseTracker::Ledger') }

        describe 'POST /expenses' do
            context 'when the expense is successfully recorded' do
                let(:expense) { { 'some' => 'data'} }

                # before hook - is included in the scope of each it block when the test cases are run
                # each test gets its own copy of the variables assigned here
                # these examples use DRY (Don't Repeat Yourself Principle)
                before do
                    # calling allow from rspec-mocks
                    # allow configures the test double's behavior
                    # when the caller (API) invokes the record, the double will return a new RecordResult instance
                    # indicating a successful posting
                    allow(ledger).to receive(:record)
                    .with(expense)
                    .and_return(RecordResult.new(true, 417, nil))
                end

                it 'returns the expense id' do
                    post '/expenses', JSON.generate(expense) 
                    expect(last_response_body).to include('expense_id' => 417)
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
                    expect(last_response_body).to include('error' => 'Expense incomplete')
                end

                it 'responds with a 422 (Unprocessable entity)' do
                    post '/expenses', JSON.generate(expense)
                    expect(last_response.status).to eq(422)
                end
            end
        end

        describe 'GET /expenses/:date' do
            context 'when expenses exist on the given date' do
                let(:date) { '2017-06-12' }

                before do
                    expenses = [
                        RecordResult.new(true, 417, nil, '2017-06-12'),
                        RecordResult.new(true, 418, nil, '2017-06-12'),
                        RecordResult.new(true, 419, nil, '2017-06-12'),
                        RecordResult.new(true, 420, nil, '2017-06-12')
                    ]

                    allow(ledger).to receive(:expenses_on)
                    .with(date)
                    .and_return(expenses) 
                end
                
                it 'returns the expense records as JSON' do
                    get "/expenses/#{date}"
                    expect(last_response_body).to contain_exactly(417, 418, 419, 420)
                end
                
                it 'responds with a 200 (OK)' do
                    get "/expenses/#{date}"
                    expect(last_response.status).to eq(200)
                end
            end

            context 'when there are no expenses on the given date' do
                let(:date) { '2012-01-01' }
                
                before do
                    allow(ledger).to receive(:expenses_on)
                    .with(date)
                    .and_return([])
                end

                it 'returns an empty array as JSON' do
                    get "/expenses/#{date}"
                    expect(last_response_body).to eq([])
                end
                
                it 'responds with a 200 (OK)' do
                    get "/expenses/#{date}"
                    expect(last_response.status).to eq(200)
                end
            end
        end
    end
end