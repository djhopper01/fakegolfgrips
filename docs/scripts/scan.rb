require 'rubygems'
require 'yaml'
require 'open-uri'
require 'nokogiri'

def say(text)
  print text
end

ROOT = File.expand_path("..", File.dirname(__FILE__))
FEEDBACK = "https://www.ebay.com/fdbk/feedback_profile/%s?filter=feedback_page:RECEIVED_AS_SELLER"
BASE_WAIT = 10
WAIT_VARIANCE = 60
MATCHING_PATTERNS = [
  "fake"
]
SUSPECTS_FILE = File.join(ROOT, "_data", "suspects.yml")

say "The current path is #{ROOT}\n"

suspects = YAML.load_file(SUSPECTS_FILE)
usernames = suspects.map { |s| s["username"] }
say "Current suspects are #{usernames.join(", ")}.\n"

usernames.each do |username|
  random_wait = BASE_WAIT + rand(WAIT_VARIANCE).to_i
  say "Waiting #{random_wait} seconds until the next one.\n"
  sleep random_wait

  say "Scanning #{username}'s profile for fake golf grips.\n"

  url = FEEDBACK % username
  say "Fetching #{url}\n"

  html = URI.open(url)
  doc = Nokogiri::HTML(html)

  MATCHING_PATTERNS.each do |pattern|
    if doc.css(".card__comment").text.include?(pattern)
      say "#{username} confirmed: #{pattern}.\n"
    end
  end

  say "Done.\n\n"
end
