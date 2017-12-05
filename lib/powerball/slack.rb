require 'slack-ruby-client'

class Powerball::Slack

  def initialize(token, channel, lottery, admins = [] )
    Slack.configure do |config|
      config.token = token
    end

    @client  = Slack::RealTime::Client.new
    @lottery = lottery
    @channel = channel
    @admins  = admins.map{|a| "@#{a}" }
    @messages = [
                  "Yay, it's drawing time!",
                  "Oh boy, I get to draw a winner!",
                  "You mean I get to pick another winner?! :allthethings:",
                  "It's time for another one. :confetti_ball:",
                  "Another drawing :game_die:, who's it gonna be?",
                  "Party on, Wayne :metal:. Draw us a winner.",
                ]

    @images   = [
                  { title: "Powerball!",
                      image_url: "https://i.giphy.com/media/Ps8XflhsT5EVa/giphy.gif"                                },
                  { title: "Who's it gonna be?",
                      image_url: "http://www.thinkgeek.com/images/products/zoom/2063_critical_hit_led_dice_set.gif" },
                  { title: "Let's roll the dice!",
                      image_url: "https://studio.code.org/v3/assets/GBhvGLEcbJGFHdJfHkChqw/8TEb9oxGc.gif"           },
                  { title: "Draw a card, any card...",
                      image_url: "https://c1.staticflickr.com/2/1262/1267623453_99002a752a_m.jpg"                   },
                  { title: "Powerball!",
                      image_url: "http://a.abcnews.com/images/US/RT_Powerball_Machine_ER_160112_4x3_992.jpg"        },
                ]

    @lottery.chatroom = self

    @client.on :hello do
      puts "Successfully connected '#{@client.self.name}' to the '#{@client.team.name}' team at https://#{@client.team.domain}.slack.com."
      # bots cannot join channels. They must be invited
      #@client.web_client.channels_join(:name => @channel)
    end

    @client.on :close do |_data|
      puts 'Connection closing, exiting.'
    end

    @client.on :closed do |_data|
      puts 'Connection has been disconnected.'
    end

    @client.on :message do |data|
      puts data

      case data.text
      when "<@#{@client.self.id}> hi", 'powerball hi', "hi <@#{@client.self.id}>", 'hi powerball' then
        @client.message channel: data.channel, text: "Hi <@#{data.user}>!"

      when "<@#{@client.self.id}> drawing", 'powerball drawing' then
        username = @client.web_client.users_info(user: data.user)['user']['name']
        next unless admins.include? username

        @lottery.drawing
      end
    end
  end

  def start!
    @client.start!
  end

  def active_members
    begin
      # The api will let you use ID or name, but only if the channel is public!
      list = @client.web_client.conversations_list(:types => 'public_channel, private_channel')
      chan = list['channels'].select { |c| c['name'] == @channel }.first['id']

      data = @client.web_client.conversations_members( :channel => chan, :limit => 500 )
      data['members'].map do |user|
        # we only want active users!
        next unless @client.web_client.users_getPresence(:user => user)['presence'] == 'active'

        @client.web_client.users_info(:user => user)['user']['name'] rescue nil
      end.compact
    rescue => e
      puts 'ERROR: cannot list channel members'
      puts e.message
      puts e.backtrace.join "\n"
      []
    end
  end

  def start_drawing
    begin
      @client.web_client.chat_postMessage({
                                              channel: @channel,
                                                 text: @messages.sample,
                                          attachments: [@images.sample],
                                              as_user: true,
                                        })
    rescue => e
      puts 'ERROR: cannot start drawing'
      puts e.message
      puts e.backtrace.join "\n"
    end
  end

  def post_winner(winner)
    begin
      slack = @client.web_client.users_info(user: "@#{winner}")['user']['id']
      @client.web_client.chat_postMessage({
                                        channel: @channel,
                                           text: "Congratulations <@#{slack}>, you're our latest winner! :tada: :clap:",
                                        as_user: true,
                                      })
      return true
    rescue => e
      puts 'ERROR: drawing incomplete'
      puts e.message
      puts e.backtrace.join "\n"
      return false
    end
  end

  def alert_admins(message)
    @admins.each do |admin|
      begin
        channel = @client.web_client.im_open(:user => admin)['channel']['id']
        @client.web_client.chat_postMessage({ channel: channel, text: message, as_user: true })
      rescue => e
        puts "ERROR: could not send message to #{admin}"
      end
    end
  end

end