require 'sqlite3'

# Create database
db = SQLite3::Database.new('development.sqlite3')

puts "Setting up gym class management database..."

# Create instructors table
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS instructors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    specialization VARCHAR(255) NOT NULL,
    bio TEXT,
    phone VARCHAR(255),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
  );
SQL

# Create gym_classes table
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS gym_classes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    duration INTEGER NOT NULL,
    capacity INTEGER NOT NULL,
    enrolled_count INTEGER DEFAULT 0,
    schedule_time DATETIME NOT NULL,
    instructor_id INTEGER NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (instructor_id) REFERENCES instructors (id)
  );
SQL

# Insert sample data
puts "Adding sample instructors..."
instructors = [
  ["Sarah Johnson", "sarah@gymapp.com", "Yoga & Pilates", "Certified yoga instructor with 8 years of experience.", "555-0101"],
  ["Mike Rodriguez", "mike@gymapp.com", "CrossFit & HIIT", "Former CrossFit Games competitor, specializing in high-intensity training.", "555-0102"],
  ["Emily Chen", "emily@gymapp.com", "Spinning & Cardio", "Energetic spinning instructor who loves helping people reach their fitness goals.", "555-0103"],
  ["David Thompson", "david@gymapp.com", "Weight Training", "Personal trainer with focus on strength training and muscle building.", "555-0104"]
]

instructors.each do |instructor|
  db.execute("INSERT OR IGNORE INTO instructors (name, email, specialization, bio, phone) VALUES (?, ?, ?, ?, ?)", instructor)
end

puts "Adding sample gym classes..."
# Get instructor IDs
instructor_ids = db.execute("SELECT id FROM instructors ORDER BY id")

base_time = Time.now.strftime('%Y-%m-%d')
classes = [
  ["Morning Yoga Flow", "Start your day with gentle yoga flow", 60, 20, 8, "#{base_time} 07:00:00", instructor_ids[0][0]],
  ["CrossFit Bootcamp", "High-intensity functional fitness", 45, 15, 12, "#{base_time} 18:00:00", instructor_ids[1][0]],
  ["Spin Class", "High-energy indoor cycling", 50, 25, 20, "#{base_time} 06:30:00", instructor_ids[2][0]],
  ["Strength Training 101", "Learn proper lifting technique", 75, 12, 5, "#{base_time} 19:00:00", instructor_ids[3][0]],
]

classes.each do |gym_class|
  db.execute("INSERT OR IGNORE INTO gym_classes (name, description, duration, capacity, enrolled_count, schedule_time, instructor_id) VALUES (?, ?, ?, ?, ?, ?, ?)", gym_class)
end

db.close

puts "Database setup complete!"
puts "You can now start the Rails server with 'ruby server.rb'"