# redMine - project management software
# Copyright (C) 2006-2007  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module Jrc
  module Helpers
    
    # Simple class to compute the start and end dates of a calendar
    class Calendar
      attr_reader :startdt, :enddt

      def initialize(date, period = :month)
        @date = date
        @events = []
        @ending_events_by_days = {}
        @starting_events_by_days = {}
        case period
        when :month
          @startdt = Date.civil(date.year, date.month, 1)
          @enddt = (@startdt >> 1)-1
          # starts from the first day of the week
          @startdt = @startdt - (@startdt.cwday - first_wday)%7
          # ends on the last day of the week
          @enddt = @enddt + (last_wday - @enddt.cwday)%7
        when :week
          @startdt = date - (date.cwday - first_wday)%7
          @enddt = date + (last_wday - date.cwday)%7
        else
          raise 'Invalid period'
        end
      end
      
      # Sets calendar events
      def events=(events)
        @events = events
        @ending_events_by_days = @events.group_by {|event| event.due_date}
        @starting_events_by_days = @events.group_by {|event| event.start_date}
      end
      
      # Returns events for the given day
      def events_on(day)
        ((@ending_events_by_days[day] || []) + (@starting_events_by_days[day] || [])).uniq
      end
      
      # Calendar current month
      def month
        @date.month
      end
      
      # Return the first day of week
      # 1 = Monday ... 7 = Sunday
      def first_wday
        @first_dow ||= 7
      end
      
      def last_wday
        @last_dow ||= 6
      end
    end    
  end
end
