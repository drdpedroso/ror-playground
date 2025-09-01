class GymClass < ApplicationRecord
  belongs_to :instructor
  
  validates :name, presence: true
  validates :description, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :capacity, presence: true, numericality: { greater_than: 0 }
  validates :schedule_time, presence: true
  
  scope :upcoming, -> { where('schedule_time > ?', Time.current) }
  scope :today, -> { where(schedule_time: Date.current.beginning_of_day..Date.current.end_of_day) }
  
  def full?
    enrolled_count >= capacity
  end
  
  def available_spots
    capacity - enrolled_count
  end
end