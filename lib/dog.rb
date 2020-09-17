class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(hash)
      @id = hash[:id]
      @name = hash[:name]
      @breed = hash[:breed]
    end

    def self.create_table
      sql = "CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
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
           sql = "INSERT INTO dogs (name, breed) VALUES (?,?)"
           DB[:conn].execute(sql, self.name, self.breed)
           @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(hash)
      dog = self.new(hash)
      dog.save
      dog
    end

    def self.new_from_db(row)
      new_dog = self.new({id: row[0], name: row[1], breed: row[2]})
    end

    def self.find_by_id(id)
      eye_d = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
      self.new_from_db(eye_d)
    end

    def self.find_or_create_by(hash)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", 
      hash[:name], hash[:breed])
        if !dog.empty?
            data = dog[0]
            new_dog = self.new({id: data[0], name: data[1], breed: data[2]})
        else
            new_dog = self.create(hash)
        end
    end

    def self.find_by_name(name)
       data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).first
       self.new({id: data[0], name: data[1], breed: data[2]})
    end

    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end