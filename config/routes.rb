Rails.application.routes.draw do
	resources :feeds do
		member do
			resources :articles, only: [:index, :show]
		end
	end 	
	get 'welcome' => 'feeds#welcome'
	get 'form_search' => 'feeds#form_search'
	get 'search' => 'feeds#search'
	get 'feeds/:id/edit(:format)' => 'feeds#edit', as: 'edit_feed_path'
	get 'info' => 'feeds#info'
	root 'feeds#welcome'

	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
