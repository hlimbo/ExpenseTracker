require_relative '../../config/sequel'

# following code makes sure the database structure is setup and empty:
# this defines a suite-level hook (this hook will run once: after all specs have been loaded, but before the first one actually runs)
RSpec.configure do |c|
    c.before(:suite) do # before(:suite) hook will run after all specs have loaded, but before the first spec runs
        Sequel.extension :migration, :core_extensions
        Sequel::Migrator.run(DB, 'db/migrations') # creates a sqlite3 table
        DB[:expenses].truncate # cleans database
    end
end