require_relative 'questions_database'
require_relative 'users'
require_relative 'questions'

class QuestionFollow
  attr_accessor :question_id, :author_id

  def initialize(options)
    @question_id = options['question_id']
    @author_id = options['author_id'] #user_id
  end

  def self.followers_for_question_id(question_id)
    data = QuestionDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.id, users.fname, users.lname
    FROM
      question_follows
    JOIN
      users
    ON
      question_follows.author_id = users.id
    WHERE
      question_id = ?
    SQL
    data.map {|datum| User.new(datum)}
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      questions.id, questions.title, questions.body, questions.author_id
    FROM
      question_follows
    JOIN
      questions
    ON
      question_follows.question_id = questions.id
    WHERE
      question_follows.author_id = ?
    SQL
    data.map {|datum| Question.new(datum)}
  end

  def self.most_followed_questions(n) #limit n
    data = QuestionDatabase.instance.execute(<<-SQL, n)
    SELECT
      question_id, questions.title, questions.body, questions.author_id
    FROM
      question_follows
    JOIN
      questions
    ON
      question_follows.question_id = questions.id
    GROUP BY
      question_id
    ORDER BY
      COUNT(question_follows.author_id) DESC
    LIMIT
      ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed
    QuestionFollow.most_followed_questions(1)
  end

end