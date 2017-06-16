class Dog
attr_accessor :id, :name, :breed

  def initialize(name:, breed:, id:nil)
    @id = id
    @name = name
    @breed = breed
    # binding.pry

  end

  def self.create_table
    Dog.drop_table
    sql = <<-SQL
    CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
    # binding.pry
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE if exists dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-Table
      INSERT INTO dogs (name, breed) VALUES (?, ?)
      Table
      #need to get last ID number

      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("Select last_insert_rowid() From dogs")[0][0]
      # binding.pry
      self
    end

  end

  def update
    sql = "Update dogs Set name = ?, breed = ? Where id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)

  end

  def self.create(hash_object)
    # binding.pry
    new_dog = Dog.new(hash_object)
    new_dog.save


  end

  def self.new_from_db(row_data)
    # new_name = row_data[:name]
    # new_breed = row_data[:breed]
    # binding.pry
    dog_hash = {name: row_data[1], breed: row_data[2], id: row_data[0]}
    Dog.new(dog_hash)

  end

  def self.find_by_id(num)
    sql = <<-SQL
    Select * from dogs where id = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, num).flatten)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    Select * from dogs where name = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, name).flatten)
  end

  def self.find_or_create_by(hash_object)
    # new_object = Dog.new(hash_object)
    # new_object.id = DB[:conn].execute("Select id From dogs where name = ?", new_object.name)[0][0]
    # binding.pry
    sql = <<-SQL
    Select * from dogs where name = ? and breed = ?
    SQL
    results = DB[:conn].execute(sql, hash_object[:name], hash_object[:breed]).flatten
    # binding.pry

    if results.length !=  0
      self.new_from_db(results)
    # # elsif self.find_by_name(new_object.name)
    #   # existing_dog = self.find_by_name(new_object.name)
    #   # existing_dog.id
    else
    #   # binding.pry
      self.create(hash_object)

    end


  end



end
