require_relative '../config/environment'

puts "Setting up database..."

# Create tables
ActiveRecord::Base.connection.execute <<-SQL
  CREATE TABLE IF NOT EXISTS instructors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    specialization VARCHAR(255) NOT NULL,
    bio TEXT,
    phone VARCHAR(255),
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL
  );
SQL

ActiveRecord::Base.connection.execute <<-SQL
  CREATE TABLE IF NOT EXISTS gym_classes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    duration INTEGER NOT NULL,
    capacity INTEGER NOT NULL,
    enrolled_count INTEGER DEFAULT 0,
    schedule_time DATETIME NOT NULL,
    instructor_id INTEGER NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    FOREIGN KEY (instructor_id) REFERENCES instructors (id)
  );
SQL

puts "Database tables created!"
puts "Run 'ruby db/seeds.rb' to add sample data."