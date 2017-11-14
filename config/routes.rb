Rails.application.routes.draw do
	resources :feeds do
		member do
			resources :articles, only: [:index, :show]
		end
	end 
	
	#get 'all' => 'articles#all'	
	get 'welcome' => 'feeds#welcome'
	get 'search' => 'feeds#search_open'
	get 'download' => 'feeds#download'
	root 'feeds#index'
	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
