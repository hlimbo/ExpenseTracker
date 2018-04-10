require_relative '../config/sequel'

module ExpenseTracker
    RecordResult = Struct.new(:success?, :expense_id, :error_message,:date)

    class Ledger
        def record(expense)
            DB[:expenses].insert(expense)
            id = DB[:expenses].max(:id)
            return RecordResult.new(true,id,nil)
        end

        def expenses_on(date)
            return []
        end
    end
end