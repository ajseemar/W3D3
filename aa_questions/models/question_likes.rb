require_relative 'questions_database'
require_relative 'users'

class QuestionLike
  attr_accessor :question_id, :author_id

  def initialize(options)
    @question_id = options['question_id']
    @author_id = options['author_id']
  end

  def self.likers_for_question_id(question_id)
    data = QuestionDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.id, users.fname, users.lname
    FROM
      question_likes
    JOIN
      users
    ON
      question_likes.author_id = users.id
    WHERE
      question_id = ?
    SQL
    data.map {|datum| User.new(datum)}
  end

  def self.num_likes_for_question_id(question_id)
    data = QuestionDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      COUNT(author_id) AS num_likes
    FROM
      question_likes
    WHERE
      question_id = ?
    
    SQL
    data.first['num_likes']
  end

  def self.liked_questions_for_user_id(user_id)
    data = QuestionDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      question_id, questions.title, questions.body, questions.author_id
    FROM
      question_likes
    JOIN
      questions
    ON
      question_likes.question_id = questions.id
    WHERE
      question_likes.author_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def self.most_liked_questions(n)
    data = QuestionDatabase.instance.execute(<<-SQL, n)
    SELECT
      question_id, questions.title, questions.body, questions.author_id
    FROM
      question_likes
    JOIN
      questions
    ON
      question_likes.question_id = questions.id
    GROUP BY
      question_likes.question_id
    ORDER BY
      COUNT(question_likes.author_id) DESC
    LIMIT
      ?
    SQL
    data.map {|datum| Question.new(datum)}
  end

end