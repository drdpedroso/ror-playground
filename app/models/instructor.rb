class Instructor < ApplicationRecord
  has_many :gym_classes, dependent: :destroy
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :specialization, presence: true
end