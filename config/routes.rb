Rails.application.routes.draw do
  root 'gym_classes#index'
  
  resources :gym_classes do
    member do
      patch :enroll
      patch :unenroll
    end
  end
  
  resources :instructors
end