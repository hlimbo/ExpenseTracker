# to create a database using sqlite3 adapter with ruby Sequel type:
# bundle exec sequel -m ./db/migrations sqlite://db/development.rb --echo

Sequel.migration do
    change do
        create_table :expenses do
            primary_key :id
            String :payee
            Float :amount
            Date :date
        end
    end
end
