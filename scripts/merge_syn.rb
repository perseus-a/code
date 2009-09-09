#! /usr/bin/ruby

#--
###############################################################################
#                                                                             #
# merge_syn -- Intersection of Lingo results for perseus-a                    #
#                                                                             #
# Copyright (C) 2009 Cologne University of Applied Sciences,                  #
#                    Claudiusstr. 1,                                          #
#                    50678 Cologne, Germany                                   #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@uni-koeln.de>                                    #
#                                                                             #
# merge_syn is free software; you can redistribute it and/or modify it under  #
# the terms of the GNU General Public License as published by the Free        #
# Software Foundation; either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# merge_syn is distributed in the hope that it will be useful, but WITHOUT    #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or       #
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for    #
# more details.                                                               #
#                                                                             #
# You should have received a copy of the GNU General Public License along     #
# with merge_syn. If not, see <http://www.gnu.org/licenses/>.                 #
#                                                                             #
###############################################################################
#++

abort "Usage: #{$0} <in.syn>... <out.syn>" unless ARGV.size >= 2

STDOUT.sync = true

KEY_SEPARATOR   = '*'.freeze
VALUE_SEPARATOR = '|'.freeze

merge = Hash.new { |h, k| h[k] = [] }
outfile = ARGV.pop

# first run sets the basis!
File.foreach(ARGV.shift) { |line|
  print '.' if $. % 1_000 == 0

  line.chomp!

  key, values = line.split(KEY_SEPARATOR, 2)
  merge[key] = values.split(VALUE_SEPARATOR)
}

keys = merge.keys

puts

ARGV.each { |syn|
  _keys = []

  File.foreach(syn) { |line|
    print '.' if $. % 1_000 == 0

    line.chomp!

    key, values = line.split(KEY_SEPARATOR, 2)
    merge[key] &= values.split(VALUE_SEPARATOR)

    _keys << key
  }

  keys &= _keys

  puts
}

merge.delete_if { |key, values|
  values.empty? || !keys.include?(key)
}

puts

File.open(outfile, 'w') { |f|
  merge.sort.each_with_index { |(key, values), i|
    print '.' if i % 1_000 == 0

    f.puts "#{key}#{KEY_SEPARATOR}#{values.sort.join(VALUE_SEPARATOR)}"
  }
}

puts
