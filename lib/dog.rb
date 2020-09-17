class Dog
attr_accessor :id ,:name,:breed
def initialize (id: nil ,name:,breed:)
    @id=id
    @name=name
    @breed=breed        
end

def self.create_table
    sql= <<-SQL
    CREATE TABLE dogs (id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT);
    SQL
    DB[:conn].execute(sql)
end

def self.drop_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
end

def save
    DB[:conn].execute('INSERT INTO dogs (name,breed) VALUES(?,?)',self.name,self.breed)
    self.id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
end

def self.create(hash)
    new= Dog.new(name:hash[:name], breed:hash[:breed])
    new.save
end

def self.new_from_db(row)
    Dog.new(id:row[0], name:row[1], breed:row[2])
end

def self.find_by_id(id)
    result= DB[:conn].execute('SELECT * FROM dogs WHERE id=?',id).first
    new_from_db(result)
end

def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id:dog_data[0], name:dog_data[1], breed:dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
end

def self.find_by_name(name)
    row=DB[:conn].execute("SELECT * FROM dogs WHERE name = ?",name).first
    new_from_db(row)
end

def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
end

end