require 'csv'

class Powerball::Lottery
#     first   = item[2]
#     last    = item[3]
#     email   = item[4]
#     slack   = item[13]
#     company = item[16]
#     addr1   = item[17]
#     addr2   = item[18]
#     city    = item[19]
#     state   = item[20]
#     zip     = item[21]
#     country = item[22]
#     phone   = item[23]

  def initialize(attendees = 'attendees.csv', winners = 'winners.csv')
    @winners   = CSV.read(winners) rescue []
    @attendees = CSV.read(attendees) rescue []
    @header    = @attendees.shift # remove header

    @winners.shift
    @attendees = @attendees - @winners # remove existing winners

    @attendees.reject! do |attendee|
      email   = attendee[4].strip.downcase
      company = attendee[16].strip.downcase

      (company == 'puppet'                \
        || email.end_with?('@puppet.com') \
        || email.end_with?('@puppetlabs.com'))
    end

    @attendees.map! do |attendee|
      attendee[13].strip!
      attendee[13].slice!(0) if attendee[13].start_with?('@')

      attendee
    end

    puts "INFO: #{@attendees.size} eligible attendees"
  end

  def chatroom=(chatroom)
    @chatroom = chatroom
  end

  def drawing
    @chatroom.start_drawing

    active = @chatroom.active_members
    pool   = @attendees.select do |attendee|
      active.include? attendee[13]
    end

    puts "INFO: eligible participants: #{pool.map {|a| "#{a[2]} #{a[3]} (#{a[13]})" }.inspect}"

    if pool.size > 0
      winner = pool.sample
      @winners << winner
      @attendees.delete winner

      @chatroom.post_winner(winner[13])
      @chatroom.alert_admins("New winner: #{winner[2]} #{winner[3]} (#{winner[13]})")
      write_winners
    else
      @chatroom.alert_admins("WARNING: there are no currently eligible participants.")
    end
  end

  def write_winners
    CSV.open('winners.csv', "wb") do |csv|
      csv << @header # copy the input header
      @winners.each do |row|
        csv << row
      end
    end
  end

end