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

    def followed_questions
        QuestionFollow.followed_questions_for_user_id(self.id)
    end

    def liked_questions
        QuestionLike.liked_questions_for_user_id(self.id)
    end

    def average_karma
        data = QuestionsDBConnection.instance.execute(<<-SQL)
            SELECT num_likes.user, AVG(num_likes.count)
            FROM(
                SELECT questions.user_id as user ,COUNT(*) as count
                FROM questions
                JOIN question_likes
                ON question_likes.question_id = questions.id
                GROUP BY questions.id
            ) as num_likes
            GROUP BY num_likes.user
        SQL
        puts data
        data.map{|datum|Question.new(datum)}
    end

#   SELECT avg(count)
#   FROM
#     (
#     SELECT COUNT (*) AS Count
#       FROM Table T
#      WHERE T.Update_time =
#                (SELECT MAX (B.Update_time )
#                   FROM Table B
#                  WHERE (B.Id = T.Id))
#     GROUP BY T.Grouping
#     ) as counts
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
    def self.most_followed(n)
        QuestionFollow.most_followed_questions(n)
    end

    def self.most_liked(n)
        data = QuestionsDBConnection.instance.execute(<<-SQL, n)
            SELECT *
            FROM questions
            JOIN question_likes
            ON question_likes.question_id = questions.id
            GROUP BY questions.id
            ORDER BY COUNT(*) DESC
            LIMIT ?;
        SQL
        data.map{|datum| Question.new(datum)}
    end

    def initialize(options) #array of all attributes
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @user_id = options['user_id']
    end

    def author
        User.find_by_id(self.user_id)
    end

    def replies
        Reply.find_by_question_id(self.id)
    end

    def followers
        QuestionFollow.followers_for_question_id(self.id)
    end

    def likers
        QuestionLike.likers_for_question_id(self.id)
    end

    def num_likes
        QuestionLike.num_likes_for_question_id(self.id)
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
    def self.find_by_id(reference_id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, reference_id)
            SELECT * 
            FROM replies
            WHERE id = ?;
        SQL
        data.map {|datum| Reply.new(datum)}
    end
    def self.find_by_reference_id(id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT * 
            FROM replies
            WHERE reference_id = ?;
        SQL
        data.map {|datum| Reply.new(datum)}
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
    def author
        User.find_by_id(self.user_id)
    end
    def question
        Question.find_by_id(self.question_id)
    end
    def parent_reply
        Reply.find_by_id(self.reference_id)
    end
    def child_replies
        Reply.find_by_reference_id(self.id)
    end
end

class QuestionFollow
    attr_accessor :id, :user_id, :question_id

    def initialize(options)
        @id = options['id']
        @user_id = options['user_id']
        @question_id = options['question_id']
    end

    def self.followers_for_question_id(question_id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
            SELECT users.id, users.fname, users.lname
            FROM users
            JOIN question_follows 
            ON question_follows.user_id = users.id
            WHERE question_follows.question_id = ?;
        SQL
        data.map{|datum| User.new(datum)}
    end

    def self.followed_questions_for_user_id(user_id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
            SELECT questions.id, questions.title, questions.body, questions.user_id
            FROM questions
            JOIN question_follows
            ON question_follows.question_id = questions.id
            WHERE question_follows.user_id = ?;
        SQL
        data.map{|datum| Question.new(datum)}
    end

    def self.most_followed_questions(n)
        data = QuestionsDBConnection.instance.execute(<<-SQL, n)
            SELECT questions.id, questions.title, questions.body, questions.user_id
            FROM questions
            JOIN question_follows
            ON question_follows.question_id = questions.id
            GROUP BY questions.id
            ORDER BY COUNT(questions.id) DESC
            LIMIT ?;
        SQL
        data.map{|datum| Question.new(datum)}
    end
end

class QuestionLike
    attr_accessor :id, :user_id, :question_id

    def initialize(options)
        @id = options['id']
        @user_id = options['user_id']
        @question_id = options['question_id']
    end

    def self.likers_for_question_id(question_id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
            SELECT *
            FROM question_likes
            WHERE question_id = ?;
        SQL
        data.map{|datum| QuestionLike.new(datum)}
    end

    def self.num_likes_for_question_id(question_id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
            SELECT COUNT(*)
            FROM question_likes
            WHERE question_id = ?
        SQL
        data
    end

    def self.liked_questions_for_user_id(user_id)
        data = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
            SELECT *
            FROM question_likes
            WHERE user_id = ?;
        SQL
        data.map{|datum| QuestionLike.new(datum)}
    end

    def self.most_liked_questions(n)
        data = QuestionsDBConnection.instance.execute(<<-SQL, n)
            SELECT *
            FROM questions
            JOIN question_likes
            ON question_likes.question_id = questions.id
            GROUP BY questions.id
            ORDER BY COUNT(*) DESC
            LIMIT ?;
        SQL
        data.map {|datum| QuestionLike.new(datum)}
    end
end
