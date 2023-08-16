require 'sqlite3'
require 'singleton'

class QuestionsDBConnection < SQLite3::Database
    include Singleton
    def initialize
        super('questions.db')
        self.type_translation = true
        self.results_as_hash = true 
    end
end

class User
    def self.find_by_id(id)
        QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT * 
            FROM users
            WHERE id = ?; 
        SQL
    end
end