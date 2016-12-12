require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize (name: nil, breed: nil, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end



  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end


  def self.create (attributes = {})
    new_dog = Dog.new
    new_dog.name = attributes[:name]
    new_dog.breed = attributes[:breed]
    new_dog.save
  end


  def self.find_by_id (id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = #{id}
    SQL

    self.new_from_db(DB[:conn].execute(sql)[0])
  end

  def self.new_from_db (row)
    dog = Dog.new
    dog.id = row[0]
    dog.name = row[1]
    dog.breed = row[2]
    # dog.save
    dog
  end

  def self.find_or_create_by(name:, breed:)
     dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1 ", name, breed)
     if !dog.empty?
      #  binding.pry
       self.new_from_db(dog[0])
     else
       self.create(name: name, breed: breed)
     end
   end

   def self.find_by_name(name)
     sql = "SELECT * FROM dogs WHERE name = ?"
     result = DB[:conn].execute(sql,name)
    #  @id = result [0][0]
     new_from_db(result[0])
    #  binding.pry
   end

   def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end







end
