require 'net/http'
require 'open-uri'
require 'nokogiri'
require 'pry'

class Page

  attr_accessor :url, :bylines, :stories

  def initialize(url)
    @url = url
    @bylines = []
    @stories = []
  end

  def document
    Nokogiri::HTML(open(@url))
  end

  def front_page_stories
    self.document.css('.story')
  end

  def create_stories
    self.front_page_stories.each do |story|
      if story.css('h6.byline').text != ""
        s = Story.new
        if story.css('h2').text != ""
          s.headline = story.css('h2').text.strip
        elsif story.css('h3').text != ""
          s.headline = story.css('h3').text.strip
        elsif story.css('h5').text != ""
          s.headline = story.css('h5').text.strip
        end
      s.link = story.css('a').attribute("href").value
      s.byline = story.css('h6.byline').text.strip
      s.lede_graph = story.css('p').text.strip
      @stories << s
      end
    end
  end

  def read_stories
    self.create_stories
    @stories.each do |story|
      story.speak_story
    end
  end

end

class Story
  attr_accessor :headline, :byline, :lede_graph, :link

  def initialize
    @doc = ""
    @body_paragraphs = []
  end

  def doc
    @doc = Nokogiri::HTML(open(@link))
  end

  def full_text
    self.doc
    @doc.css("p[itemprop=articleBody]").each do |p|
      @body_paragraphs << p.text.strip
    end
    @body_paragraphs
  end

  def speak(method)
    `say "#{self.send(method)}"`
  end

  def speak_story
    puts "#{self.byline}"
    `say "#{self.byline}"`
    puts "#{self.headline}"
    `say "#{self.headline}"`
    puts "#{self.lede_graph}"
    `say "#{self.lede_graph}"`
    self.full_text.each do |p|
      puts "#{p}"
      `say "#{p}"`
    end
  end

end

news = Page.new("http://www.nytimes.com")
news.read_stories
