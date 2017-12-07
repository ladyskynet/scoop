require 'csv'
require 'date'
require 'tf-idf-similarity'
require 'matrix'
#require date necessary at top of file

class FeedsController < ApplicationController

  # GET /feeds
  # GET /feeds.json
  def index
    @feeds = Feed.all
  end

  # GET /feeds/1
  # GET /feeds/1.json
  def show
    @feed = Feed.find(params[:id])
  end

  # GET /feeds/new
  def new
    @feed = Feed.new
  end

  # GET /feeds/1/edit
  def edit
    @feed = Feed.find(params[:id])
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
    #total_list = "Title, Author, Published, Word Count, Readability, Feed ID\n"
    total_list = "Title, Author, Published, Word Count, String Length, Letter Count, Readability, Sentimentality, Sentence Count, URL, Syllable Count, Average Syllables per Word, Average Words per Sentence, Number of Photos\n"
    @from = params[:from]
    @to = params[:to]
    begin
      start =
        unless @from.nil?
          if @from.empty?
            DateTime.new(2001,2,3,4,5,6)
          else
            DateTime.strptime(@from, "%m/%d/%Y")
          end
        end
      last =
        unless @to.nil?
          if @to.empty?
            DateTime.now
          else
            DateTime.strptime(@to, "%m/%d/%Y").change({ hour: 23, min: 59, sec: 59 })
          end
        end
      @article_list = Array.new
      @feeds_selected.each do |feed|
 
        # Finds all articles that have relevant results
        @article_results = feed.articles.search_for(params[:search]).each {|article|}

        @article_results.each do |article_tiny|
          unless article_tiny.published.nil?
            #puts article_tiny  
            if(article_tiny.published >= start && article_tiny.published <= last)
              #puts(article_tiny.published)
              @article_list.push(article_tiny)
            end
            #puts article_tiny.title
            #puts article_tiny.author
            unless article_tiny.author.nil? or article_tiny.title.nil?
              row_string = [article_tiny.title.tap { |s| s.delete!(',') },
                            article_tiny.author.tap { |s| s.delete!(',') },  
                            article_tiny.published.to_s, 
                            article_tiny.wordcount.to_s, 
                            article_tiny.string_length.to_s,
                            article_tiny.letter_count.to_s,
                            article_tiny.readability.to_s,
                            article_tiny.sentimentality.to_s,
                            article_tiny.sentence_count.to_s,
                            article_tiny.url,
                            article_tiny.syllable_count.to_s,
                            article_tiny.average_syllables_per_word.to_s,
                            article_tiny.average_words_per_sentence.to_s,
                            article_tiny.photos.count.to_s].reject(&:blank?).join(',')
              total_list += row_string + "\n"
            end
          end
        end
      end
      @similarity_list = similarityCheck(@article_list) # NEW FOR TWIST

      respond_to do |format|
        format.html
        format.csv { send_data total_list, filename: "file.csv" }
      end
    rescue => error
      puts error
      redirect_to "/form_search#formSearchAnchor"
    end
  end

  # THIS ENTIRE METHOD IS FOR THE TWIST
  def similarityCheck(articleList)
    corpus = []
    contentList = []
    count = 0
    firstInsert = nil

    #loop to load the corpus and record the content put into it for their indexes
    articleList.each do |article|
      unless article.content.empty? or article.content.nil?
        toInsert = TfIdfSimilarity::Document.new(article.content)
        if count == 0
          firstInsert = toInsert
          #remeber the first one inserted
        else
          contentList.push(toInsert)
          #put the rest in the contentList
        end
        count += 1 
        corpus.push(toInsert)
      end
    end

    #create the similarity matrix
    model = TfIdfSimilarity::TfIdfModel.new(corpus)
    simmatrix = model.similarity_matrix
    
    similarityList = []
    similarityList.push(100)
    #fill the similarity array of the articles
    contentList.each do |article2|
      similarityList.push(100*simmatrix[model.document_index(firstInsert), model.document_index(article2)])
    end
    return similarityList
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

  # PATCH/PUT /feeds/1
  # PATCH/PUT /feeds/1.json
  def update
    @feed = Feed.find(params[:id])
    results = Feed.all.search_url(feed_params[:url])
    respond_to do |format|
      if params[:id].to_i > 76
        if results.present? and results[0] != @feed.id
          puts results[0]
          flash[:danger] = "That URL has already been used. Please use a unique URL."
          format.html { redirect_to @feed}
          format.json { render json: @feed.errors, status: :unprocessable_entity }
        else
          if Feed.validate_feed(feed_params[:url])
            if @feed.update(feed_params)
              flash[:success] = "Feed was succesfully updated."
              format.html { redirect_to @feed}
              format.json { render :show, status: :ok, location: @feed }
            else
              format.html { render :edit }
              format.json { render json: @feed.errors, status: :unprocessable_entity }
            end
          else
            # Gives an error if rss feed is not valid
            flash[:danger] = "The entered URL is not a valid RSS feed."
            format.html { redirect_to @feed }
            format.json { render json: @feed.errors, status: :unprocessable_entity }
          end
        end
      else
        flash[:danger] = "This is a default feed and cannot be edited."
        format.html { redirect_to @feed }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feeds/1
  # DELETE /feeds/1.json
  def destroy
    Feed.find(params[:id]).destroy
    respond_to do |format|
      if Feed.find(params[:id]) > 76
        flash[:success] = "Feed was successfully destroyed."
        format.html { redirect_to feeds_url }
        format.json { head :no_content }
      else
        flash[:danger] = "This is a default feed and cannot be deleted."
        format.html { redirect_to @feed }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def feed_params
      params.require(:feed).permit(:name, :url, :description)
    end
end