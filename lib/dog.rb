

class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id:nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql= <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            )
            SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql= <<-SQL
        DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
        SQL
        result = DB[:conn].execute(sql, @name, @breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
          dog_data = dog[0]
          dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
    end
    
    def self.create(name:, breed:)      #CREATES, SAVES, GIVES BACK INSTANCE
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog = Dog.new(id: row[0], name: row[1], breed: row[2])
        # creates an instance with corresponding attribute values (FAILED - 5)
    end

    def self.find_by_id(id)
        sql= <<-SQL
        SELECT *
        FROM dogs
        WHERE id= ?
        SQL
        result = DB[:conn].execute(sql, id).first
        # binding.pry
        # Dog.new(result[0], result[1], result[2])
        Dog.new_from_db(result)
        Dog.new_from_db(DB[:conn].execute(sql, id).first)
        # returns a new dog object by id (FAILED - 6)
    end

    def self.find_by_name(name)
        sql= <<-SQL
        SELECT *
        FROM dogs
        WHERE name= ?
        SQL
        # DB[:conn].execute(sql, name).first
        Dog.new_from_db(DB[:conn].execute(sql, name).first)
        # returns a new dog object by id (FAILED - 6)
    end

    def update
        # binding.pry
        sql= <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
        SQL
        result = DB[:conn].execute(sql, name, breed, self.id).first
        
    end


    


end
