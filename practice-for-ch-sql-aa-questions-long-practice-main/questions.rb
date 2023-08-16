require 'sqlite3'
require 'singleton'
require 'byebug'

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
        # fname = QuestionsDBConnection.instance.execute(<<-SQL, id)
        #     SELECT fname
        #     FROM users
        #     WHERE id = ?;
        # SQL
        # lname = QuestionsDBConnection.instance.execute(<<-SQL, id)
        #     SELECT lname
        #     FROM users
        #     WHERE id = ?;
        # SQL
        # User.new({'id' => id, 'fname' => fname, 'lname' => lname})
        data = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT * 
            FROM users
            WHERE id = ?;
        SQL
        debugger
        data.map{|datum| User.new(datum)}
    end

    def initialize(options) #array of all attributes
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end
end

        # QuestionsDBConnection.instance.execute(<<-SQL, id)
        #     SELECT * 
        #     FROM users
        #     WHERE id = ?; 
        # SQL