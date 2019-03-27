require_relative 'questions_database'
require_relative 'questions'
require_relative 'users'

class Reply
  attr_accessor :id, :question_id, :parent_reply_id, :author_id, :body

  def self.find_by_id(id)
    data = QuestionDatabase.instance.execute(<<-SQL, id)
    SELECT 
      *
    FROM
      replies
    WHERE
      id = ?
    SQL
    Reply.new(data.first)
  end

  def self.find_by_user_id(user_id)
    data = QuestionDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      replies
    WHERE
      author_id = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(question_id)
    data = QuestionDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      replies
    WHERE
      question_id = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @author_id = options['author_id']
    @body = options['body']
  end

  def author
    User.find_by_id(self.author_id)
  end

  def question
    Question.find_by_id(self.question_id)
  end

  def parent_reply
    raise "no parent" if self.parent_reply_id.nil?
    Reply.find_by_id(self.parent_reply_id)
  end

  def child_replies
    data = QuestionDatabase.instance.execute(<<-SQL, self.id)
    SELECT
      *
    FROM
      replies
    WHERE
      parent_reply_id = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end

  def save
    if self.id.nil?
      #insert it :id, :question_id, :parent_reply_id, :author_id, :body
      QuestionDatabase.instance.execute(<<-SQL, self.question_id, self.parent_reply_id, self.author_id, self.body)
        INSERT INTO
          replies (question_id, parent_reply_id, author_id, body)
        VALUES
          (?, ?, ?, ?)
      SQL
      self.id = QuestionDatabase.instance.last_insert_row_id
    else
      #update it
      QuestionDatabase.instance.execute(<<-SQL, self.question_id, self.parent_reply_id, self.author_id, self.body self.id)
      UPDATE
        replies
      SET
        question_id = ?,
        parent_reply_id = ?,
        author_id = ?,
        body_id = ?
      WHERE
        replies.id = ?
      SQL
    end
  end

end