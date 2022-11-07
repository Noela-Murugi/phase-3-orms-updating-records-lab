require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :album
  attr_reader :id
    def initialize(name , grade , id= nil)
      @id = id
      @name = name
      @grade = grade
    end
    def self.create_table
      query = <<-SQL
          CREATE TABLE students (
              id INTEGER PRIMARY KEY,
              name TEXT,
              grade TEXT
          )
      SQL
      DB[:conn].execute(query)
    end

    def self.drop_table
      query = <<-SQL
          DROP TABLE IF EXISTS students
      SQL
      DB[:conn].execute(query)
    end

    def save
      query = <<-SQL
          INSERT INTO Student(name, grade) VALUES(?, ?)
      SQL
      DB[:conn].execute(query, self.name, self.grade)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      self
    end


    def self.create name: , grade:
      student = Student.new(name: name, grade: grade)
      student.save
  end

  def self.new_from_db row
      self.new(id: row[0], name:row[1], grade:row[2])
  end

  def self.all
      query = <<-SQL
          SELECT * FROM students
      SQL
      DB[:conn].execute(query).map do |row|
          self.new_from_db(row)
      end
  end

  def self.find_by_name name
      query = <<-SQL
          SELECT * FROM students
          WHERE name = ?
          LIMIT 1
      SQL
      DB[:conn].execute(query, name).map do |row|
          self.new_from_db(row)
      end.first
  end

  def self.find id
      query = <<-SQL
          SELECT * FROM students
          WHERE id = ?
          LIMIT 1
      SQL
      DB[:conn].execute(query, id).map do |row|
          self.new_from_db(row)
      end.first
  end
end
