class Dog

    attr_accessor :name, :breed, :id

    def initialize (name:, breed:, id: nil)
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
        sql = <<-SQL 
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        new_dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = last_insert_rowid()")
        Dog.new(name: new_dog[1], breed: new_dog[2], id: @id)
    end

    def self.create (dog_hash)
        name = dog_hash[:name]
        breed = dog_hash[:breed]

        dog = Dog.new(name: name, breed: breed)        
        dog.save
        dog
    end

    def self.new_from_db (row)
        new_dog = Dog.new(name: row[1], breed: row[2], id: row[0])
        new_dog
    end

    def self.find_by_id (id)
        sql = <<-SQL 
            SELECT * FROM dogs
            WHERE id = ?
        SQL

        row = DB[:conn].execute(sql, id)[0]
        new_dog = Dog.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.find_or_create_by (dog_hash)
        name = dog_hash[:name]
        breed = dog_hash[:breed]

        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            dog_info = dog[0]
            dog = Dog.new(name: dog_info[1], breed: dog_info[2], id: dog_info[0])
        else
            dog = self.create(dog_hash)
        end
    end

    def self.find_by_name (name)
        sql = <<-SQL 
            SELECT * FROM dogs
            WHERE name = ?
        SQL

        row = DB[:conn].execute(sql, name)[0]
        new_dog = Dog.new(name: row[1], breed: row[2], id: row[0])
    end

    def update
        sql = <<-SQL 
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)

    end

end