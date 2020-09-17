require 'pry'
class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = "CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
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

    def self.create(hash)
        new_dog = Dog.new(hash)
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        id =row[0]
        name = row[1]
        breed = row[2]
        Dog.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        results = DB[:conn].execute(sql, id)[0]
        Dog.new(id: results[0], name: "#{results[1]}", breed: "#{results[2]}")
    end

    def self.find_or_create_by(hash)
        sql = "SELECT * FROM dogs WHERE  name = ? AND breed = ?"
        results = DB[:conn].execute(sql, hash[:name], hash[:breed])[0]
        if results
            Dog.new(id: results[0], name: "#{results[1]}", breed: "#{results[2]}")
        else
            self.create(hash)
        end
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        results = DB[:conn].execute(sql, name)[0]
        Dog.new(id: results[0], name: "#{results[1]}", breed: "#{results[2]}")
    end


    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end