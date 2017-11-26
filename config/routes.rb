Rails.application.routes.draw do
	resources :feeds do
		member do
			resources :articles, only: [:index, :show]
		end
	end 
	
	#get 'all' => 'articles#all'	
	get 'welcome' => 'feeds#welcome'
	get 'form_search' => 'feeds#form_search'
	get 'search' => 'feeds#search'
	#GET    /movies/:id(.:format)      movies#show
	get 'feeds/:id/edit(:format)' => 'feeds#edit', as: 'edit_feed_path'
	get 'info' => 'feeds#info'
	#get 'download' => 'feeds#download'
	root 'feeds#welcome'

	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
