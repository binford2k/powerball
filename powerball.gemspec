require 'date'

Gem::Specification.new do |s|
  s.name              = "powerball"
  s.version           = '0.0.2'
  s.date              = Date.today.to_s
  s.summary           = "Slack lotto bot."
  s.homepage          = "https://github.com/binford2k/powerball/"
  s.email             = "binford2k@gmail.com"
  s.authors           = ["Ben Ford"]
  s.license           = "Apache-2.0"
  s.has_rdoc          = false
  s.require_path      = "lib"
  s.executables       = %w( powerball )
  s.files             = %w( README.md )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")

  s.add_dependency      "clockwork"
  s.add_dependency      "slack-ruby-client"
  s.add_dependency      "faye-websocket"

  s.description       = <<-desc
    This is a stupid simple Slack bot that just draws a winner each hour from
    a CSV specified list. It's single purpose in design, so it's quite unlikely
    to be of any use to you.
  desc
end
