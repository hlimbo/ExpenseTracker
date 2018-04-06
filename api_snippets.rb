class API < Sinatra::Base
    def initialize(ledger:)
        @ledger = ledger
        super() # rest of initialization from Sinatra
    end
end

# Later, callers do this:
# This technique is known as dependency injection (DI for short)
app = API.new(ledger: Ledger.new)

# Here we are testing the API we are about to write for Ledger class
# Clarification: We are not testing the behavior of the Ledger class here!
result = @ledger.record({ 'some' => 'data' })
result.success? # => a Boolean
result.expense_id # => a number
result.error_message # => a string or nil