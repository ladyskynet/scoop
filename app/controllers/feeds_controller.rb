class FeedsController < ApplicationController
  before_action :set_feed, only: [:show, :edit, :update, :destroy]

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
  end

  def welcome
  end

def search
  begin
    #Finds the feeds that were selcted by checkboxes
    @selected = params[:selected]
    @feeds_selected = Feed.find(@selected)
    #Handles if no feeds were selected
  rescue
    @feeds_selected = Feed.all
  end

  open('/Users/ecombs/Documents/outputFile3.txt', 'a') { |f|
  #f.puts "Title" }
  @feeds_selected.each do |feed|
    #Finds all articles that have relevant results
    @article_results = feed.articles.search_for(params[:search]).each {|article|}
    open('/Users/ecombs/Documents/outputFile3.txt', 'a') { |f|
      #Puts the results into a file
      @article_results.each do |articlebaby|
        f.puts (articlebaby.title)
      end
    }
  end

  @feeds_selected = Feed.all
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
        format.html { redirect_to @feed, notice: 'The url already been used for a previous feed, not saved' }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      else
        #Checks to see if given url is a valid rss feed
        if Feed.validate_feed(feed_params[:url])
          if @feed.save
            #Saves the feed to the database if url is valid
            format.html { redirect_to @feed, notice: 'Feed was successfully created.' }
            format.json { render :show, status: :created, location: @feed }
          else
            format.html { render :new, notice: 'That url has already been used for a previous feed' }
            format.json { render json: @feed.errors, status: :unprocessable_entity }
          end
        else
          #Gives an error if rss feed is not valid
          format.html { redirect_to @feed, notice: 'The given url is not a valid rss feed' }
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
        format.html { redirect_to @feed, notice: 'Feed was successfully updated.' }
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
      format.html { redirect_to feeds_url, notice: 'Feed was successfully destroyed.' }
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