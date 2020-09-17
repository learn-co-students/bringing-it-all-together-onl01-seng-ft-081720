class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(hash)
        @id = hash[:id]
        @name = hash[:name]
        @breed = hash[:breed]
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed  TEXT);")[0]
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs;")
    end

    def save
        if self.id
            self.update
        else        
            sql = "INSERT INTO dogs (id, name, breed) VALUES (?,?,?)"
            DB[:conn].execute(sql, self.id, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(hash)
        doggo = self.new(hash)
        doggo.save
        doggo
    end

    def self.new_from_db(row)
        doggo = self.new({id: row[0], name: row[1], breed: row[2]})
    end

    def self.find_by_id(id)
        data = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id) [0]
        self.new_from_db(data)
    end

    def self.find_or_create_by(hash)
        doggo = DB[:conn].execute("SELECT * FROM dogs WHERE name=? AND breed=?", hash[:name], hash[:breed])
        if !doggo.empty?
            data = doggo[0]
            new_dog = self.new({id: data[0], name: data[1], breed: data[2]})
        else
            new_dog = self.create(hash)
        end
    end

    def self.find_by_name(name)
        data = DB[:conn].execute("SELECT * FROM dogs WHERE name=?", name).first
        self.new({id: data[0], name: data[1], breed: data[2]})
    end

    def update
        sql = "UPDATE dogs SET name=?, breed=? WHERE id=?"
        data = DB[:conn].execute(sql, self.name, self.breed, self.id)
        # binding.pry
    end
end
