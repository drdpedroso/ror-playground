require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'
require 'json'
require 'time'

# Configure Sinatra
set :port, 3000
set :public_folder, 'public'
enable :sessions

# Database connection
def db
  @db ||= SQLite3::Database.new('development.sqlite3')
  @db.results_as_hash = true
  @db
end

# Helper methods
helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
  
  def format_datetime(datetime_str)
    Time.parse(datetime_str).strftime("%A, %B %d at %I:%M %p")
  rescue
    datetime_str
  end
  
  def format_time(datetime_str)
    Time.parse(datetime_str).strftime("%I:%M %p")
  rescue
    datetime_str
  end
end

# Layout template
def layout
  <<-HTML
<!DOCTYPE html>
<html>
<head>
  <title>Gym Class Management</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 20px;
      background-color: #f5f5f5;
    }
    
    .container {
      max-width: 1200px;
      margin: 0 auto;
      background-color: white;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .header {
      background-color: #2563eb;
      color: white;
      padding: 20px;
      margin: -20px -20px 20px -20px;
      border-radius: 8px 8px 0 0;
    }
    
    .nav {
      margin: 10px 0;
    }
    
    .nav a {
      color: white;
      text-decoration: none;
      margin-right: 20px;
      font-weight: bold;
    }
    
    .nav a:hover {
      text-decoration: underline;
    }
    
    .btn {
      display: inline-block;
      padding: 10px 15px;
      background-color: #2563eb;
      color: white;
      text-decoration: none;
      border-radius: 4px;
      border: none;
      cursor: pointer;
    }
    
    .btn:hover {
      background-color: #1d4ed8;
    }
    
    .btn-success {
      background-color: #059669;
    }
    
    .btn-danger {
      background-color: #dc2626;
    }
    
    .btn-warning {
      background-color: #d97706;
    }
    
    .card {
      border: 1px solid #e5e7eb;
      border-radius: 8px;
      padding: 20px;
      margin-bottom: 20px;
      background-color: white;
    }
    
    .alert {
      padding: 15px;
      margin-bottom: 20px;
      border-radius: 4px;
    }
    
    .alert-success {
      background-color: #d1fae5;
      color: #065f46;
      border: 1px solid #a7f3d0;
    }
    
    .alert-error {
      background-color: #fee2e2;
      color: #991b1b;
      border: 1px solid #fca5a5;
    }
    
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 20px;
    }
    
    th, td {
      padding: 12px;
      text-align: left;
      border-bottom: 1px solid #e5e7eb;
    }
    
    th {
      background-color: #f9fafb;
      font-weight: bold;
    }
    
    .form-group {
      margin-bottom: 15px;
    }
    
    label {
      display: block;
      margin-bottom: 5px;
      font-weight: bold;
    }
    
    input, textarea, select {
      width: 100%;
      padding: 8px;
      border: 1px solid #d1d5db;
      border-radius: 4px;
      font-size: 14px;
      box-sizing: border-box;
    }
    
    textarea {
      height: 100px;
      resize: vertical;
    }
    
    .grid {
      display: grid;
      gap: 20px;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>💪 Gym Class Management</h1>
      <div class="nav">
        <a href="/">Classes</a>
        <a href="/gym_classes">All Classes</a>
        <a href="/instructors">Instructors</a>
        <a href="/gym_classes/new">New Class</a>
        <a href="/instructors/new">New Instructor</a>
      </div>
    </div>
    
    CONTENT_PLACEHOLDER
  </div>
</body>
</html>
  HTML
end

# Routes

# Home page - List gym classes
get '/' do
  today = Time.now.strftime('%Y-%m-%d')
  @gym_classes = db.execute("
    SELECT gc.*, i.name as instructor_name 
    FROM gym_classes gc 
    JOIN instructors i ON gc.instructor_id = i.id 
    WHERE date(gc.schedule_time) > date('now')
    ORDER BY gc.schedule_time
  ")
  
  @today_classes = db.execute("
    SELECT gc.*, i.name as instructor_name 
    FROM gym_classes gc 
    JOIN instructors i ON gc.instructor_id = i.id 
    WHERE date(gc.schedule_time) = date('now')
    ORDER BY gc.schedule_time
  ")
  
  content = "<h2>Gym Classes</h2>"
  content += '<a href="/gym_classes/new" class="btn">Add New Class</a>'
  
  if @today_classes.any?
    content += "<h3>Today's Classes</h3>"
    content += '<div class="grid">'
    @today_classes.each do |gym_class|
      content += <<-HTML
        <div class="card">
          <h4>#{h gym_class['name']}</h4>
          <p><strong>Instructor:</strong> #{h gym_class['instructor_name']}</p>
          <p><strong>Time:</strong> #{format_time(gym_class['schedule_time'])}</p>
          <p><strong>Duration:</strong> #{gym_class['duration']} minutes</p>
          <p><strong>Spots:</strong> #{gym_class['enrolled_count']}/#{gym_class['capacity']}</p>
          <div style="margin-top: 10px;">
            <a href="/gym_classes/#{gym_class['id']}" class="btn">View</a>
            <a href="/gym_classes/#{gym_class['id']}/edit" class="btn btn-warning">Edit</a>
          </div>
        </div>
      HTML
    end
    content += '</div>'
  end
  
  content += "<h3>Upcoming Classes</h3>"
  if @gym_classes.any?
    content += '<div class="grid">'
    @gym_classes.each do |gym_class|
      available = gym_class['capacity'] - gym_class['enrolled_count']
      content += <<-HTML
        <div class="card">
          <h4>#{h gym_class['name']}</h4>
          <p><strong>Instructor:</strong> #{h gym_class['instructor_name']}</p>
          <p><strong>Date & Time:</strong> #{format_datetime(gym_class['schedule_time'])}</p>
          <p><strong>Duration:</strong> #{gym_class['duration']} minutes</p>
          <p><strong>Spots Available:</strong> #{available} of #{gym_class['capacity']}</p>
          <p>#{h gym_class['description'][0..100]}...</p>
          <div style="margin-top: 10px;">
            <a href="/gym_classes/#{gym_class['id']}" class="btn">View Details</a>
            <a href="/gym_classes/#{gym_class['id']}/edit" class="btn btn-warning">Edit</a>
            <form action="/gym_classes/#{gym_class['id']}/delete" method="post" style="display:inline;">
              <button type="submit" class="btn btn-danger" onclick="return confirm('Are you sure?')">Delete</button>
            </form>
          </div>
        </div>
      HTML
    end
    content += '</div>'
  else
    content += '<p>No upcoming classes scheduled.</p>'
  end
  
  layout.sub('CONTENT_PLACEHOLDER', content)
end

# List all gym classes
get '/gym_classes' do
  redirect '/'
end

# Show single gym class
get '/gym_classes/:id' do
  @gym_class = db.execute("
    SELECT gc.*, i.name as instructor_name, i.specialization 
    FROM gym_classes gc 
    JOIN instructors i ON gc.instructor_id = i.id 
    WHERE gc.id = ?
  ", params[:id]).first
  
  return "Class not found" unless @gym_class
  
  available = @gym_class['capacity'] - @gym_class['enrolled_count']
  full = available <= 0
  
  content = <<-HTML
    <h2>#{h @gym_class['name']}</h2>
    <div class="card">
      <p><strong>Description:</strong> #{h @gym_class['description']}</p>
      <p><strong>Instructor:</strong> <a href="/instructors/#{@gym_class['instructor_id']}">#{h @gym_class['instructor_name']}</a></p>
      <p><strong>Specialization:</strong> #{h @gym_class['specialization']}</p>
      <p><strong>Date & Time:</strong> #{format_datetime(@gym_class['schedule_time'])}</p>
      <p><strong>Duration:</strong> #{@gym_class['duration']} minutes</p>
      <p><strong>Capacity:</strong> #{@gym_class['capacity']} people</p>
      <p><strong>Currently Enrolled:</strong> #{@gym_class['enrolled_count']}</p>
      <p><strong>Available Spots:</strong> 
        <span style="color: #{available > 0 ? 'green' : 'red'};">#{available}</span>
      </p>
      #{full ? '<p style="color: red; font-weight: bold;">⚠️ This class is full!</p>' : ''}
    </div>
    
    <div style="margin-top: 20px;">
      #{!full ? "<form action='/gym_classes/#{@gym_class['id']}/enroll' method='post' style='display:inline;'><button type='submit' class='btn btn-success'>Enroll in Class</button></form>" : ''}
      #{@gym_class['enrolled_count'] > 0 ? "<form action='/gym_classes/#{@gym_class['id']}/unenroll' method='post' style='display:inline;'><button type='submit' class='btn btn-warning'>Unenroll from Class</button></form>" : ''}
      <a href="/gym_classes/#{@gym_class['id']}/edit" class="btn">Edit Class</a>
      <form action="/gym_classes/#{@gym_class['id']}/delete" method="post" style="display:inline;">
        <button type="submit" class="btn btn-danger" onclick="return confirm('Are you sure?')">Delete Class</button>
      </form>
      <a href="/" class="btn">Back to Classes</a>
    </div>
  HTML
  
  layout.sub('CONTENT_PLACEHOLDER', content)
end

# New gym class form
get '/gym_classes/new' do
  @instructors = db.execute("SELECT * FROM instructors ORDER BY name")
  
  content = <<-HTML
    <h2>Create New Gym Class</h2>
    <form action="/gym_classes" method="post">
      <div class="form-group">
        <label for="name">Name</label>
        <input type="text" id="name" name="name" required>
      </div>
      
      <div class="form-group">
        <label for="description">Description</label>
        <textarea id="description" name="description" required></textarea>
      </div>
      
      <div class="form-group">
        <label for="instructor_id">Instructor</label>
        <select id="instructor_id" name="instructor_id" required>
          <option value="">Select an instructor</option>
          #{@instructors.map { |i| "<option value='#{i['id']}'>#{h i['name']}</option>" }.join}
        </select>
      </div>
      
      <div class="form-group">
        <label for="schedule_time">Date & Time</label>
        <input type="datetime-local" id="schedule_time" name="schedule_time" required>
      </div>
      
      <div class="form-group">
        <label for="duration">Duration (minutes)</label>
        <input type="number" id="duration" name="duration" min="15" max="180" required>
      </div>
      
      <div class="form-group">
        <label for="capacity">Maximum Capacity</label>
        <input type="number" id="capacity" name="capacity" min="1" max="50" required>
      </div>
      
      <div>
        <button type="submit" class="btn btn-success">Create Class</button>
        <a href="/" class="btn">Cancel</a>
      </div>
    </form>
  HTML
  
  layout.sub('CONTENT_PLACEHOLDER', content)
end

# Create gym class
post '/gym_classes' do
  db.execute("
    INSERT INTO gym_classes (name, description, duration, capacity, enrolled_count, schedule_time, instructor_id)
    VALUES (?, ?, ?, ?, 0, ?, ?)
  ", params[:name], params[:description], params[:duration], params[:capacity], params[:schedule_time], params[:instructor_id])
  
  redirect "/gym_classes/#{db.last_insert_row_id}"
end

# Edit gym class form
get '/gym_classes/:id/edit' do
  @gym_class = db.execute("SELECT * FROM gym_classes WHERE id = ?", params[:id]).first
  @instructors = db.execute("SELECT * FROM instructors ORDER BY name")
  
  return "Class not found" unless @gym_class
  
  content = <<-HTML
    <h2>Edit Gym Class</h2>
    <form action="/gym_classes/#{@gym_class['id']}" method="post">
      <div class="form-group">
        <label for="name">Name</label>
        <input type="text" id="name" name="name" value="#{h @gym_class['name']}" required>
      </div>
      
      <div class="form-group">
        <label for="description">Description</label>
        <textarea id="description" name="description" required>#{h @gym_class['description']}</textarea>
      </div>
      
      <div class="form-group">
        <label for="instructor_id">Instructor</label>
        <select id="instructor_id" name="instructor_id" required>
          #{@instructors.map { |i| 
            selected = i['id'] == @gym_class['instructor_id'] ? 'selected' : ''
            "<option value='#{i['id']}' #{selected}>#{h i['name']}</option>" 
          }.join}
        </select>
      </div>
      
      <div class="form-group">
        <label for="schedule_time">Date & Time</label>
        <input type="datetime-local" id="schedule_time" name="schedule_time" value="#{@gym_class['schedule_time'].gsub(' ', 'T')}" required>
      </div>
      
      <div class="form-group">
        <label for="duration">Duration (minutes)</label>
        <input type="number" id="duration" name="duration" value="#{@gym_class['duration']}" min="15" max="180" required>
      </div>
      
      <div class="form-group">
        <label for="capacity">Maximum Capacity</label>
        <input type="number" id="capacity" name="capacity" value="#{@gym_class['capacity']}" min="1" max="50" required>
      </div>
      
      <div>
        <button type="submit" class="btn btn-success">Update Class</button>
        <a href="/gym_classes/#{@gym_class['id']}" class="btn">Show</a>
        <a href="/" class="btn">Back</a>
      </div>
    </form>
  HTML
  
  layout.sub('CONTENT_PLACEHOLDER', content)
end

# Update gym class
post '/gym_classes/:id' do
  db.execute("
    UPDATE gym_classes 
    SET name = ?, description = ?, duration = ?, capacity = ?, schedule_time = ?, instructor_id = ?
    WHERE id = ?
  ", params[:name], params[:description], params[:duration], params[:capacity], params[:schedule_time], params[:instructor_id], params[:id])
  
  redirect "/gym_classes/#{params[:id]}"
end

# Delete gym class
post '/gym_classes/:id/delete' do
  db.execute("DELETE FROM gym_classes WHERE id = ?", params[:id])
  redirect '/'
end

# Enroll in class
post '/gym_classes/:id/enroll' do
  gym_class = db.execute("SELECT * FROM gym_classes WHERE id = ?", params[:id]).first
  if gym_class && gym_class['enrolled_count'] < gym_class['capacity']
    db.execute("UPDATE gym_classes SET enrolled_count = enrolled_count + 1 WHERE id = ?", params[:id])
  end
  redirect "/gym_classes/#{params[:id]}"
end

# Unenroll from class
post '/gym_classes/:id/unenroll' do
  gym_class = db.execute("SELECT * FROM gym_classes WHERE id = ?", params[:id]).first
  if gym_class && gym_class['enrolled_count'] > 0
    db.execute("UPDATE gym_classes SET enrolled_count = enrolled_count - 1 WHERE id = ?", params[:id])
  end
  redirect "/gym_classes/#{params[:id]}"
end

# List instructors
get '/instructors' do
  @instructors = db.execute("SELECT * FROM instructors ORDER BY name")
  
  content = <<-HTML
    <h2>Instructors</h2>
    <a href="/instructors/new" class="btn">Add New Instructor</a>
    
    <div class="grid" style="margin-top: 20px;">
      #{@instructors.map { |instructor|
        class_count = db.execute("SELECT COUNT(*) as count FROM gym_classes WHERE instructor_id = ?", instructor['id']).first['count']
        <<-CARD
          <div class="card">
            <h4>#{h instructor['name']}</h4>
            <p><strong>Email:</strong> #{h instructor['email']}</p>
            <p><strong>Specialization:</strong> #{h instructor['specialization']}</p>
            #{instructor['phone'] ? "<p><strong>Phone:</strong> #{h instructor['phone']}</p>" : ''}
            #{instructor['bio'] ? "<p><strong>Bio:</strong> #{h instructor['bio'][0..100]}...</p>" : ''}
            <p><strong>Classes:</strong> #{class_count} scheduled</p>
            <div style="margin-top: 10px;">
              <a href="/instructors/#{instructor['id']}" class="btn">View</a>
              <a href="/instructors/#{instructor['id']}/edit" class="btn btn-warning">Edit</a>
              <form action="/instructors/#{instructor['id']}/delete" method="post" style="display:inline;">
                <button type="submit" class="btn btn-danger" onclick="return confirm('Are you sure? This will also delete all associated classes.')">Delete</button>
              </form>
            </div>
          </div>
        CARD
      }.join}
    </div>
  HTML
  
  layout.sub('CONTENT_PLACEHOLDER', content)
end

# Show instructor
get '/instructors/:id' do
  @instructor = db.execute("SELECT * FROM instructors WHERE id = ?", params[:id]).first
  return "Instructor not found" unless @instructor
  
  @classes = db.execute("
    SELECT * FROM gym_classes 
    WHERE instructor_id = ? AND date(schedule_time) >= date('now')
    ORDER BY schedule_time
  ", params[:id])
  
  content = <<-HTML
    <h2>#{h @instructor['name']}</h2>
    <div class="card">
      <p><strong>Email:</strong> #{h @instructor['email']}</p>
      <p><strong>Specialization:</strong> #{h @instructor['specialization']}</p>
      #{@instructor['phone'] ? "<p><strong>Phone:</strong> #{h @instructor['phone']}</p>" : ''}
      #{@instructor['bio'] ? "<p><strong>Bio:</strong> #{h @instructor['bio']}</p>" : ''}
    </div>
    
    <h3>Upcoming Classes</h3>
    #{@classes.any? ? 
      "<table>
        <thead>
          <tr>
            <th>Class Name</th>
            <th>Date & Time</th>
            <th>Duration</th>
            <th>Enrolled/Capacity</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          #{@classes.map { |c|
            "<tr>
              <td>#{h c['name']}</td>
              <td>#{format_datetime(c['schedule_time'])}</td>
              <td>#{c['duration']} min</td>
              <td>#{c['enrolled_count']}/#{c['capacity']}</td>
              <td>
                <a href='/gym_classes/#{c['id']}' class='btn'>View</a>
                <a href='/gym_classes/#{c['id']}/edit' class='btn btn-warning'>Edit</a>
              </td>
            </tr>"
          }.join}
        </tbody>
      </table>" : 
      "<p>No upcoming classes scheduled for this instructor.</p>"}
    
    <div style="margin-top: 20px;">
      <a href="/instructors/#{@instructor['id']}/edit" class="btn">Edit Instructor</a>
      <form action="/instructors/#{@instructor['id']}/delete" method="post" style="display:inline;">
        <button type="submit" class="btn btn-danger" onclick="return confirm('Are you sure? This will also delete all associated classes.')">Delete Instructor</button>
      </form>
      <a href="/instructors" class="btn">Back to Instructors</a>
    </div>
  HTML
  
  layout.sub('CONTENT_PLACEHOLDER', content)
end

# New instructor form
get '/instructors/new' do
  content = <<-HTML
    <h2>Create New Instructor</h2>
    <form action="/instructors" method="post">
      <div class="form-group">
        <label for="name">Name</label>
        <input type="text" id="name" name="name" required>
      </div>
      
      <div class="form-group">
        <label for="email">Email</label>
        <input type="email" id="email" name="email" required>
      </div>
      
      <div class="form-group">
        <label for="specialization">Specialization (e.g., Yoga, CrossFit, Pilates)</label>
        <input type="text" id="specialization" name="specialization" required>
      </div>
      
      <div class="form-group">
        <label for="phone">Phone</label>
        <input type="tel" id="phone" name="phone">
      </div>
      
      <div class="form-group">
        <label for="bio">Biography (optional)</label>
        <textarea id="bio" name="bio"></textarea>
      </div>
      
      <div>
        <button type="submit" class="btn btn-success">Create Instructor</button>
        <a href="/instructors" class="btn">Cancel</a>
      </div>
    </form>
  HTML
  
  layout.sub('CONTENT_PLACEHOLDER', content)
end

# Create instructor
post '/instructors' do
  db.execute("
    INSERT INTO instructors (name, email, specialization, bio, phone)
    VALUES (?, ?, ?, ?, ?)
  ", params[:name], params[:email], params[:specialization], params[:bio], params[:phone])
  
  redirect "/instructors/#{db.last_insert_row_id}"
end

# Edit instructor form
get '/instructors/:id/edit' do
  @instructor = db.execute("SELECT * FROM instructors WHERE id = ?", params[:id]).first
  return "Instructor not found" unless @instructor
  
  content = <<-HTML
    <h2>Edit Instructor</h2>
    <form action="/instructors/#{@instructor['id']}" method="post">
      <div class="form-group">
        <label for="name">Name</label>
        <input type="text" id="name" name="name" value="#{h @instructor['name']}" required>
      </div>
      
      <div class="form-group">
        <label for="email">Email</label>
        <input type="email" id="email" name="email" value="#{h @instructor['email']}" required>
      </div>
      
      <div class="form-group">
        <label for="specialization">Specialization</label>
        <input type="text" id="specialization" name="specialization" value="#{h @instructor['specialization']}" required>
      </div>
      
      <div class="form-group">
        <label for="phone">Phone</label>
        <input type="tel" id="phone" name="phone" value="#{h @instructor['phone'] || ''}">
      </div>
      
      <div class="form-group">
        <label for="bio">Biography</label>
        <textarea id="bio" name="bio">#{h @instructor['bio'] || ''}</textarea>
      </div>
      
      <div>
        <button type="submit" class="btn btn-success">Update Instructor</button>
        <a href="/instructors/#{@instructor['id']}" class="btn">Show</a>
        <a href="/instructors" class="btn">Back</a>
      </div>
    </form>
  HTML
  
  layout.sub('CONTENT_PLACEHOLDER', content)
end

# Update instructor
post '/instructors/:id' do
  db.execute("
    UPDATE instructors 
    SET name = ?, email = ?, specialization = ?, bio = ?, phone = ?
    WHERE id = ?
  ", params[:name], params[:email], params[:specialization], params[:bio], params[:phone], params[:id])
  
  redirect "/instructors/#{params[:id]}"
end

# Delete instructor (and associated classes)
post '/instructors/:id/delete' do
  db.execute("DELETE FROM gym_classes WHERE instructor_id = ?", params[:id])
  db.execute("DELETE FROM instructors WHERE id = ?", params[:id])
  redirect '/instructors'
end

# Start the server
puts "Starting Gym Class Management Server..."
puts "Visit: http://localhost:3000"