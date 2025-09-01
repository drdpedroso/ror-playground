class InstructorsController < ApplicationController
  before_action :set_instructor, only: [:show, :edit, :update, :destroy]
  
  def index
    @instructors = Instructor.all.order(:name)
  end
  
  def show
    @classes = @instructor.gym_classes.upcoming.order(:schedule_time)
  end
  
  def new
    @instructor = Instructor.new
  end
  
  def create
    @instructor = Instructor.new(instructor_params)
    
    if @instructor.save
      redirect_to @instructor, notice: 'Instructor was successfully created.'
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @instructor.update(instructor_params)
      redirect_to @instructor, notice: 'Instructor was successfully updated.'
    else
      render :edit
    end
  end
  
  def destroy
    @instructor.destroy
    redirect_to instructors_url, notice: 'Instructor was successfully deleted.'
  end
  
  private
  
  def set_instructor
    @instructor = Instructor.find(params[:id])
  end
  
  def instructor_params
    params.require(:instructor).permit(:name, :email, :specialization, :bio, :phone)
  end
end