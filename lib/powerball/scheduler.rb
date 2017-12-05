require 'clockwork'
require 'time'

module Clockwork
  class << self;
    attr_accessor :lottery
  end

  handler do |job|
    @lottery.drawing
  end

  #every(30.seconds, 'frequent.job')
  every(1.hour, 'drawing', :at => '**:00')
end
