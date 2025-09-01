# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a simple Ruby on Rails application for managing gym classes. It's designed to be used for QA candidate evaluation, featuring basic CRUD operations and relationships between instructors and gym classes.

## Application Features

- **Instructor Management**: Create, view, edit, and delete gym instructors
- **Gym Class Management**: Create, view, edit, and delete fitness classes
- **Class Enrollment**: Simple enrollment/unenrollment system with capacity tracking
- **Scheduling**: Classes are scheduled with date/time and show upcoming vs. today's classes
- **Responsive Design**: Basic responsive layout with clean styling

## Architecture

### Models
- `Instructor`: Has many gym_classes, with validations for name, email (unique), and specialization
- `GymClass`: Belongs to instructor, with validations and scopes for upcoming/today's classes
- Database: SQLite3 for simplicity

### Controllers
- `GymClassesController`: Full CRUD plus enroll/unenroll actions
- `InstructorsController`: Full CRUD operations
- `ApplicationController`: Base controller with CSRF protection

### Views
- Responsive layout with embedded CSS in `application.html.erb`
- Card-based design for displaying classes and instructors
- Forms with validation error handling
- Navigation between different sections

## Common Commands

### Setup and Development
- `bundle install` - Install gem dependencies
- `ruby setup.rb` - Initialize database and add sample data
- `ruby server.rb` - Start development server (alternative to rails server due to compatibility issues)
- Visit http://localhost:3000 to use the application

### Database
- Database file: `development.sqlite3`
- Tables: `instructors`, `gym_classes`
- Sample data includes 4 instructors and several scheduled classes

### Testing Areas for QA

This application provides numerous testing scenarios:
- Form validation (required fields, email format, capacity limits)
- CRUD operations for both models
- Enrollment/unenrollment logic with capacity checking
- Date/time handling for class scheduling
- Responsive design across different screen sizes
- Navigation between pages
- Error handling and user feedback
- Data relationships (cascade deletes, foreign keys)

## Key Files Structure

```
app/
├── controllers/
│   ├── application_controller.rb
│   ├── gym_classes_controller.rb
│   └── instructors_controller.rb
├── models/
│   ├── application_record.rb
│   ├── gym_class.rb
│   └── instructor.rb
└── views/
    ├── layouts/application.html.erb
    ├── gym_classes/
    └── instructors/
```

## Environment Notes

- Ruby 3.1.4
- Rails 6.1.x (due to compatibility constraints)
- SQLite3 database
- No JavaScript framework dependencies
- Self-contained CSS styling