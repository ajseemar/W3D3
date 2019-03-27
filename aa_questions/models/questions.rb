require_relative 'questions_database'
require_relative 'users'
require_relative 'replies'
require_relative 'question_follows'
require_relative 'question_likes'

class Question
  attr_accessor :id, :title, :body, :author_id
  def self.find_by_id(id)
    data = QuestionDatabase.instance.execute(<<-SQL, id)
    SELECT *
    FROM questions
    WHERE id = ?
    SQL
    Question.new(data.first)
  end

  def self.find_by_author_id(author_id)
    data = QuestionDatabase.instance.execute(<<-SQL, author_id)
    SELECT *
    FROM questions
    WHERE author_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def author
    User.find_by_id(self.author_id)
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

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def save
    if self.id.nil?
      QuestionDatabase.instance.execute(<<-SQL, self.title, self.body, self.author_id)
        INSERT INTO
          questions (title, body, author_id)
        VALUES
          (?, ?, ?)
      SQL
      self.id = QuestionDatabase.instance.last_insert_row_id
    else
      #update it
      QuestionDatabase.instance.execute(<<-SQL, self.title, self.body, self.author_id self.id)
      UPDATE
        questions
      SET
        title = ?,
        body = ?,
        author_id = ?,
      WHERE
        replies.id = ?
      SQL
    end
  end

end