require 'net/http'
require 'open-uri'
require 'nokogiri'
require 'pry'

class Page

  attr_accessor :url, :bylines, :stories

  def initialize(url)
    @url = url
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
        s.get_headline(story)
        s.get_byline(story)
        s.get_link(story)
        s.get_lede_graph(story)
        @stories << s
      end
    end
  end

  def read_stories
    self.create_stories
    @stories.each do |story|
      `say -v "#{story.voice}" "Story #{@stories.index(story)+1} of #{@stories.size}"`
      story.speak_story
    end
  end

end

class Story
  attr_accessor :headline, :byline, :lede_graph, :link, :voice

  VOICES = [
    "Alex",
    "Bruce",
    "Fred",
    "Junior",
    "Ralph",
    "Agnes",
    "Kathy",
    "Princess",
    "Vicki",
    "Victoria"
  ]

  def initialize
    @doc = ""
    @body_paragraphs = []
    @voice = VOICES[0] # .shuffle[0]
  end

  def doc
    @doc = Nokogiri::HTML(open(@link))
  end

  def get_link(story)
    self.link = story.css('a').attribute("href").value
  end

  def get_byline(story)
    self.byline = story.css('h6.byline').text.strip
  end

  def get_lede_graph(story)
    self.lede_graph = story.css('p').text.strip
  end

  def get_headline(story)
    attrs = ['h2', 'h3', 'h5']
    attrs.each do |headline|
      if story.css(headline).text != ""
        self.headline ||= story.css(headline).text.strip
      end
    end
  end

  def full_text
    self.doc
    @doc.css("p[itemprop=articleBody]").each do |p|
      @body_paragraphs << p.text.strip
    end
    @body_paragraphs
  end

  def speak_story
    puts "#{self.byline}"
    `say -v "#{self.voice}" "#{self.byline}"`
    puts "#{self.headline}"
    `say -v "#{self.voice}" "#{self.headline}"`
    puts "#{self.lede_graph}"
    `say -v "#{self.voice}" "#{self.lede_graph}"`
    self.full_text.each do |p|
      puts "#{p}"
      `say -v "#{self.voice}" "#{p}"`
    end
  end

end

# Connect with twitter

news = Page.new("http://www.nytimes.com")
news.read_stories

