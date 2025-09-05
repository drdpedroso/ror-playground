class GymClassesController < ApplicationController
  before_action :set_gym_class, only: [:show, :edit, :update, :destroy, :enroll, :unenroll]
  
  def index
    @gym_classes = GymClass.includes(:instructor).upcoming
    @today_classes = GymClass.includes(:instructor).today

    # Apply filters
    if params[:name].present?
      @gym_classes = @gym_classes.where("name ILIKE ?", "%#{params[:name]}%")
      @today_classes = @today_classes.where("name ILIKE ?", "%#{params[:name]}%")
    end

    if params[:instructor_id].present?
      @gym_classes = @gym_classes.where(instructor_id: params[:instructor_id])
      @today_classes = @today_classes.where(instructor_id: params[:instructor_id])
    end

    @gym_classes = @gym_classes.order(:schedule_time)
    @today_classes = @today_classes.order(:schedule_time)
    @instructors = Instructor.all
  end
  
  def show
  end
  
  def new
    @gym_class = GymClass.new
    @instructors = Instructor.all
  end
  
  def create
    @gym_class = GymClass.new(gym_class_params)
    @instructors = Instructor.all
    
    if @gym_class.save
      redirect_to @gym_class, notice: 'Gym class was successfully created.'
    else
      render :new
    end
  end
  
  def edit
    @instructors = Instructor.all
  end
  
  def update
    if @gym_class.update(gym_class_params)
      redirect_to @gym_class, notice: 'Gym class was successfully updated.'
    else
      @instructors = Instructor.all
      render :edit
    end
  end
  
  def destroy
    @gym_class.destroy
    redirect_to gym_classes_url, notice: 'Gym class was successfully deleted.'
  end
  
  def enroll
    if @gym_class.full?
      redirect_to @gym_class, alert: 'Class is full!'
    else
      @gym_class.update(enrolled_count: @gym_class.enrolled_count + 1)
      redirect_to @gym_class, notice: 'Successfully enrolled in class!'
    end
  end
  
  def unenroll
    if @gym_class.enrolled_count > 0
      @gym_class.update(enrolled_count: @gym_class.enrolled_count - 1)
      redirect_to @gym_class, notice: 'Successfully unenrolled from class!'
    else
      redirect_to @gym_class, alert: 'No enrollments to remove!'
    end
  end
  
  private
  
  def set_gym_class
    @gym_class = GymClass.find(params[:id])
  end
  
  def gym_class_params
    params.require(:gym_class).permit(:name, :description, :duration, :capacity, :schedule_time, :instructor_id)
  end
end