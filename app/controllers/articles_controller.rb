class ArticlesController < ApplicationController
	def index
		@feed = Feed.find(params[:id])
		@articles = @feed.articles.order('published desc')
  	end

  	def show
  		@feed = Feed.find(params[:id])
		@article = Article.find(params[:id])
  	end
end
