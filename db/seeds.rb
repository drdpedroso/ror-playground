# Create sample instructors
instructors = [
  {
    name: "Sarah Johnson",
    email: "sarah@gymapp.com",
    specialization: "Yoga & Pilates",
    bio: "Certified yoga instructor with 8 years of experience in Hatha and Vinyasa yoga.",
    phone: "555-0101"
  },
  {
    name: "Mike Rodriguez",
    email: "mike@gymapp.com",
    specialization: "CrossFit & HIIT",
    bio: "Former CrossFit Games competitor, specializing in high-intensity training.",
    phone: "555-0102"
  },
  {
    name: "Emily Chen",
    email: "emily@gymapp.com",
    specialization: "Spinning & Cardio",
    bio: "Energetic spinning instructor who loves helping people reach their fitness goals.",
    phone: "555-0103"
  },
  {
    name: "David Thompson",
    email: "david@gymapp.com",
    specialization: "Weight Training",
    bio: "Personal trainer with focus on strength training and muscle building.",
    phone: "555-0104"
  }
]

puts "Creating instructors..."
created_instructors = []
instructors.each do |instructor_data|
  instructor = Instructor.find_or_create_by(email: instructor_data[:email]) do |i|
    i.name = instructor_data[:name]
    i.specialization = instructor_data[:specialization]
    i.bio = instructor_data[:bio]
    i.phone = instructor_data[:phone]
  end
  created_instructors << instructor
  puts "Created/found instructor: #{instructor.name}"
end

# Create sample gym classes
puts "Creating gym classes..."

# Classes for this week
base_time = Time.current.beginning_of_week

classes_data = [
  # Monday
  {
    name: "Morning Yoga Flow",
    description: "Start your week with a gentle yoga flow focusing on breath and mindful movement.",
    duration: 60,
    capacity: 20,
    schedule_time: base_time + 1.day + 7.hours,
    enrolled_count: 8,
    instructor: created_instructors[0]
  },
  {
    name: "CrossFit Bootcamp",
    description: "High-intensity workout combining cardio, strength training, and functional movements.",
    duration: 45,
    capacity: 15,
    schedule_time: base_time + 1.day + 18.hours,
    enrolled_count: 12,
    instructor: created_instructors[1]
  },
  
  # Tuesday
  {
    name: "Spin Class",
    description: "High-energy indoor cycling class with motivating music and varied terrain.",
    duration: 50,
    capacity: 25,
    schedule_time: base_time + 2.days + 6.hours + 30.minutes,
    enrolled_count: 20,
    instructor: created_instructors[2]
  },
  {
    name: "Strength Training 101",
    description: "Learn proper form and technique for basic weight lifting exercises.",
    duration: 75,
    capacity: 12,
    schedule_time: base_time + 2.days + 19.hours,
    enrolled_count: 5,
    instructor: created_instructors[3]
  },
  
  # Wednesday
  {
    name: "Pilates Core",
    description: "Focus on core strength and stability with classical Pilates movements.",
    duration: 55,
    capacity: 18,
    schedule_time: base_time + 3.days + 8.hours,
    enrolled_count: 15,
    instructor: created_instructors[0]
  },
  {
    name: "HIIT Cardio Blast",
    description: "Short bursts of intense exercise followed by rest periods for maximum calorie burn.",
    duration: 30,
    capacity: 20,
    schedule_time: base_time + 3.days + 17.hours + 30.minutes,
    enrolled_count: 18,
    instructor: created_instructors[1]
  },
  
  # Thursday
  {
    name: "Cycling Endurance",
    description: "Build stamina and endurance with longer intervals and hill climbs.",
    duration: 60,
    capacity: 25,
    schedule_time: base_time + 4.days + 7.hours,
    enrolled_count: 22,
    instructor: created_instructors[2]
  },
  {
    name: "Full Body Strength",
    description: "Comprehensive strength training targeting all major muscle groups.",
    duration: 60,
    capacity: 15,
    schedule_time: base_time + 4.days + 18.hours + 30.minutes,
    enrolled_count: 8,
    instructor: created_instructors[3]
  },
  
  # Friday
  {
    name: "Relaxing Yin Yoga",
    description: "End your week with deep stretches and meditation for complete relaxation.",
    duration: 75,
    capacity: 16,
    schedule_time: base_time + 5.days + 8.hours + 30.minutes,
    enrolled_count: 12,
    instructor: created_instructors[0]
  },
  {
    name: "Weekend Warrior HIIT",
    description: "Intense Friday evening workout to kick off your weekend feeling strong.",
    duration: 40,
    capacity: 20,
    schedule_time: base_time + 5.days + 17.hours,
    enrolled_count: 16,
    instructor: created_instructors[1]
  },
  
  # Saturday
  {
    name: "Saturday Spin Party",
    description: "High-energy weekend spin class with dance music and party atmosphere.",
    duration: 45,
    capacity: 30,
    schedule_time: base_time + 6.days + 9.hours,
    enrolled_count: 25,
    instructor: created_instructors[2]
  },
  {
    name: "Powerlifting Workshop",
    description: "Learn the three main powerlifting movements: squat, bench press, and deadlift.",
    duration: 90,
    capacity: 10,
    schedule_time: base_time + 6.days + 10.hours + 30.minutes,
    enrolled_count: 7,
    instructor: created_instructors[3]
  },
  
  # Next week preview
  {
    name: "Monday Morning Motivation",
    description: "Start your new week with an energizing full-body workout.",
    duration: 50,
    capacity: 20,
    schedule_time: base_time + 8.days + 7.hours + 30.minutes,
    enrolled_count: 0,
    instructor: created_instructors[1]
  }
]

classes_data.each do |class_data|
  gym_class = GymClass.find_or_create_by(
    name: class_data[:name],
    schedule_time: class_data[:schedule_time]
  ) do |gc|
    gc.description = class_data[:description]
    gc.duration = class_data[:duration]
    gc.capacity = class_data[:capacity]
    gc.enrolled_count = class_data[:enrolled_count]
    gc.instructor = class_data[:instructor]
  end
  puts "Created/found class: #{gym_class.name} on #{gym_class.schedule_time.strftime('%A at %I:%M %p')}"
end

puts "\nSeed data created successfully!"
puts "#{Instructor.count} instructors and #{GymClass.count} gym classes created."