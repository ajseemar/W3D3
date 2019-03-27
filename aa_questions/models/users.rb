require_relative 'questions_database'
require_relative 'questions'
require_relative 'replies'
require_relative 'question_follows'
require_relative 'question_likes'
class User
  attr_accessor :id, :fname, :lname
  def self.find_by_id(id)
    data = QuestionDatabase.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      users
    WHERE
      id = ?

    SQL
    User.new(data.last)
  end

  def show
    user = User.find_by(id: params[user_id])
    user ? user : nil
  end

  def self.find_by_name(fname, lname)
    data = QuestionDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT
      *
    FROM
      users
    WHERE
      fname = ? AND lname = ?

    SQL
    User.new(data.last)
  end

  def initialize(options)
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
    data = QuestionDatabase.instance.execute(<<-SQL, self.id)
    SELECT
      CAST(COUNT(DISTINCT questions.id) AS FLOAT)/COUNT(question_likes.author_id)
      AS avg_karma
    FROM
      questions
    LEFT OUTER JOIN
      question_likes
    ON
      questions.id = question_likes.question_id
    WHERE
      questions.author_id = ?
    SQL
    data.first['avg_karma']
  end

  def save
    if self.id.nil?
      #insert it
      QuestionDatabase.instance.execute(<<-SQL, self.fname, self.lname)
        INSERT INTO
          users (fname, lname)
        VALUES
          (?, ?)
      SQL
      self.id = QuestionDatabase.instance.last_insert_row_id
    else
      #update it
      QuestionDatabase.instance.execute(<<-SQL, self.fname, self.lname, self.id)
      UPDATE
        users
      SET
        fname = ?,
        lname = ?
      WHERE
        users.id = ?
      SQL
    end
  end
end