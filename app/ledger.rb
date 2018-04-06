module ExpenseTracker
    RecordResult = Struct.new(:success?, :expense_id, :error_message,:date)

    class Ledger
        def record(expense)
        end

        def expenses_on(date)
            return []
        end
    end
end