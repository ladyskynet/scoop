class ArticlesController < ApplicationController
	def index
		if params[:feedid].nil?
			@articles = Article.all.order('published desc')
		else
			@feed = Feed.find(params[:feedid])
			@articles = @feed.articles.order('published desc')
		end
  	end

  	def show
  		#@feed = Feed.find(params[:feedid])
		@article = Article.find(params[:id])
  	end

  	def images
  		if params[:articleid].nil?
			@images = Photo.all
		else
			@article = Article.find(params[:articleid])
			@images = @article.photos
		end
  	end

  	def showImage
  		#@feed = Feed.find(params[:feedid])
		@image = Photo.find(params[:id])
		unless @image.nil?
			@tags = @image.tags.all
		end
  	end
end