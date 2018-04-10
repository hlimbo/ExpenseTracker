require_relative '../../../app/ledger'
require_relative '../../support/db'

# By Default, RSpec aborts the test on the first failure
# Use :aggregate_failures tag to record the first and subsequent failures in the integration test
# tags are also known as metadata (:aggregate_failures same as aggregate_failures: true)
# By Default: RSpec runs the specs in random order - enabled via config.order = :random line in spec_helper.rb
    # this is useful for finding order dependencies (That is, specs whose behavior depends on which one runs first)
    # can repeat the random failed run by using its seed e.g. bundle exec rspec --seed 24330
    # to run all tests in random order type in bundle exec rspec --order random
    # --bisect option, RSpec will systematically run different portion of suite until it finds the smallest set that triggers a failure
    # for example running bundle exec rspec --bisect --seed 24330 outputs:
    # tells us to run: bundle exec rspec ./spec/integration/app/ledger_spec.rb[1:1:1:1,1:1:2:1] --seed 24330 where
    #   the numbers in square brackets are called example IDS
    #   example IDS indicate each example's position in its file (relative to other examples and nested groups)
module ExpenseTracker
    RSpec.describe Ledger, :aggregate_failures do
        let(:ledger) { Ledger.new }
        let(:expense) do
            {
                'payee' => 'Starbucks',
                'amount' => 5.75,
                'date' => '2017-06-10'
            }
        end

        describe '#record' do
            context 'with a valid expense' do
                it 'successfully saves the expense in the DB' do
                    result = ledger.record(expense)

                    expect(result).to be_success # checks that result.success? is true (Learn more about Dynamic Predicates page 194)
                    # a_hash_including expects our app to return data matching a certain structure
                    # in this case, a one-element array of hashes with certain keys and values
                    # this is another use of RSpec's composable matchers
                    # deviating a bit from general TDD practice here
                    expect(DB[:expenses].all).to match [a_hash_including( 
                        id: result.expense_id,
                        payee: 'Starbucks',
                        amount: 5.75,
                        date: Date.iso8601('2017-06-10')
                    )]
                end
            end

            context 'when the expense lacks a payee' do
                it 'rejects the expense as invalid' do
                    expense.delete('payee')
                    result = ledger.record(expense)

                    expect(result).not_to be_success
                    expect(result.expense_id).to eq(nil)
                    expect(result.error_message).to include('`payee` is required')

                    expect(DB[:expenses].count).to eq(0)
                end
            end
        end
    end
end