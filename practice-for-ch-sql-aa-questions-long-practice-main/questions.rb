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
    attr_accessor :id, :fname, :lname
    def self.find_by_id(id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT * 
            FROM users
            WHERE id = ?;
        SQL
        data.each{|datum| return User.new(datum)}
    end

    def self.find_by_name(fname, lname)
        data = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
            SELECT * 
            FROM users
            WHERE fname = ?
            AND lname = ?;
        SQL
        data.each{|datum| return User.new(datum)}
    end

    def initialize(options) #array of all attributes
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def authored_questions
        Question.find_by_author_id(self.id)
    end

    def authored_replies
        Reply.find_by_user_id(self.id)
    end
end

class Question
    attr_accessor :id, :title, :body, :user_id
    def self.find_by_id(id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT * 
            FROM questions
            WHERE id = ?;
        SQL
        data.each{|datum| return Question.new(datum)}
    end

    def self.find_by_title(title)
        data = QuestionsDBConnection.instance.execute(<<-SQL, title)
            SELECT * 
            FROM questions
            WHERE title = ?;
        SQL
        data.each{|datum| return Question.new(datum)}
    end

    def self.find_by_author_id(author_id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, author_id)
            SELECT *
            FROM questions
            WHERE user_id = ?;
        SQL
        data.map{|datum| Question.new(datum)}
    end

    def initialize(options) #array of all attributes
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @user_id = options['user_id']
    end
end

class Reply
    attr_accessor :id, :question_id, :reference_id, :user_id, :body
    def initialize(options)
        @id = options['id']
        @question_id = options['question_id']
        @reference_id = options['reference_id']
        @user_id = options['user_id']
        @body = options['body']
    end
    def self.find_by_user_id(user_id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
            SELECT * 
            FROM replies
            WHERE user_id = ?;
        SQL
        data.map {|datum| Reply.new(datum)}
    end
    def self.find_by_question_id(question_id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
            SELECT *
            FROM replies
            WHERE question_id = ?;
        SQL
        data.map {|datum| Reply.new(datum)}
    end
end