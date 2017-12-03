Rails.application.routes.draw do
	resources :feeds
	resources :articles, only: [:index, :show, :images]	
	get 'welcome' => 'feeds#welcome'
	get 'form_search' => 'feeds#form_search'
	get 'search(:format)' => 'feeds#search'
	get 'feeds/:id/edit(:format)' => 'feeds#edit'
	get 'articles/:feedid' => 'articles#index'
	get 'articles/:articleid/images' => 'articles#images'
	get 'articles/:articleid/image/:id' => 'articles#showImage'
	#get 'feeds/:feedid/articles/:id' => 'articles#show'
	get 'info' => 'feeds#info'
	root 'feeds#welcome'

	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
