require 'csv'

class FeedsController < ApplicationController
  before_action :set_feed, only: [:show, :edit, :update, :destroy, :welcome, :search, :form_search]

  # GET /feeds
  # GET /feeds.json
  def index
    @feeds = Feed.all
  end

  # GET /feeds/1
  # GET /feeds/1.json
  def show
  end

  # GET /feeds/new
  def new
    @feed = Feed.new
  end

  # GET /feeds/1/edit
  def edit
    feed = Feed.find(params[:id])
    @feed = feed
  end

  def welcome
  end

  def form_search
    @feeds_selected = Feed.all
  end

  def search
    begin  
      # Finds the feeds that were selcted by checkboxes
      @selected = params[:selected]
      @feeds_selected = Feed.find(@selected)
      
    # Handles if no feeds were selected
    rescue
      @feeds_selected = Feed.all
    end

    @search = params[:search]
    total_list = "Title, Author, Published, Word Count, Readability, Feed ID\n"

    @article_list = Array.new

    @feeds_selected.each do |feed|
      # Finds all articles that have relevant results
      @article_results = feed.articles.search_for(params[:search]).each {|article|}
      @article_results.each do |article_tiny|
        @article_list.push(article_tiny)
        row_string = article_tiny.title.gsub!(/,/,'') + "," + article_tiny.author.gsub!(/,/,'') + "," + article_tiny.published.to_s + "," + article_tiny.wordcount.to_s + "," + article_tiny.readability.to_s
        total_list += row_string + "\n"
      end
    end

    # send_data total_list, filename: "file.csv"
    respond_to do |format|
      format.html
      format.csv { send_data total_list, filename: "file.csv" }
    end
  end

  # POST /feeds
  # POST /feeds.json
  def create
    @feed = Feed.new(feed_params)
    respond_to do |format|
      #Checks if given url has already been used in another feed
      results = Feed.all.search_url(feed_params[:url])
      if results.present?
        #format.html { render :new, notice: 'That url has already been used for a previous feed' }
        flash[:danger] = "That URL has already been used. Please use a unique URL."
        format.html { redirect_to @feed }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      else
        #Checks to see if given url is a valid rss feed
        if Feed.validate_feed(feed_params[:url])
          if @feed.save
            flash[:success] = "Feed was successfully created."
            #Saves the feed to the database if url is valid
            format.html { redirect_to @feed }
            format.json { render :show, status: :created, location: @feed }
          else
            flash[:danger] = "That URL has already been used. Please use a unique URL."
            format.html { render :new }
            format.json { render json: @feed.errors, status: :unprocessable_entity }
          end
        else
          #Gives an error if rss feed is not valid
          flash[:danger] = "The entered URL is not a valid RSS feed."
          format.html { redirect_to @feed }
          format.json { render json: @feed.errors, status: :unprocessable_entity }
        end
      end
    end
  end
        #@feed = Feed.new(feed_params)
        
        #respond_to do |format|
        #    if @feed.save
        #        format.html { redirect_to @feed, notice: 'Feed was successfully created.' }
        #        format.json { render :show, status: :created, location: @feed }
        #    else
        #        format.html { render :new }
        #        format.json { render json: @feed.errors, status: :unprocessable_entity }
        #    end
        #end

  # PATCH/PUT /feeds/1
  # PATCH/PUT /feeds/1.json
  def update
    respond_to do |format|
      if @feed.update(feed_params)
        flash[:success] = "Feed was succesfully updated."
        format.html { redirect_to @feed }
        format.json { render :show, status: :ok, location: @feed }
      else
        format.html { render :edit }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feeds/1
  # DELETE /feeds/1.json
  def destroy
    @feed.destroy
    respond_to do |format|
      flash[:success] = "Feed was successfully destroyed."
      format.html { redirect_to feeds_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feed
      @feed = Feed.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def feed_params
      params.require(:feed).permit(:name, :url, :description)
    end
end