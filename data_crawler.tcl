#
#  Autor: Uwe Berger; 2016
#  -----------------------
#
# ======================================================================
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
# ======================================================================

package require http
package require htmlparse
package require struct

set year_begin 2000
set year_end   2016

# **********************************************
proc getpage { url } {
	set token [::http::geturl $url]
	set data [::http::data $token]
	::http::cleanup $token          
	return $data
}

# **********************************************
proc save_data {fname data} {
	set fd [open $fname w]
	puts -nonewline $fd $data
	close $fd
}

# **********************************************
proc get_node_value {n} {
	global t
	set count [$t size $n]
	#puts "--> $count"
	if {$count == 0} {return "-"}
	if {$count == 1} {return [$t get [$t children $n] data]}
	if {$count == 2} {
		return [$t get [$t children $n] data]
	}
}

# **********************************************
proc get_player_of_saison {year} {
	global t
	set url "http://www.basketball-reference.com/leagues/NBA_$year\_advanced.html"
	set data [getpage $url]
	puts $url
	puts [string length $data]
	save_data "data/player_saison_$year.txt" $data
	
	htmlparse::2tree $data $t
    htmlparse::removeVisualFluff $t
    htmlparse::removeFormDefs $t
	foreach n [$t nodes] {
		if {[$t keyexists $n data]} {
			if {([$t get $n data] == "class=\"full_table\"")} {
				set l {}
				foreach c [$t children  $n] {
					if {[$t size $c]<3} {
						set l [linsert $l end [get_node_value $c]]
						if {[$t size $c]==2} {
							set l [linsert $l end [get_node_value [$t children $c]]]
						}
					} else {
						foreach c1 [$t children $c] {
							if {[$t size $c1] > 0} {
								set l [linsert $l end [$t get $c1 data]]
								set l [linsert $l end [get_node_value $c1]]
							}
						}
					}
					
				}
				#puts $l
				#puts [lindex $l 1]
				set href [string range [lindex [split [lindex $l 1] =] 1] 1 end-1]
				#puts $href
				set url_player "http://www.basketball-reference.com$href"
				#puts $url_player
				set player [lindex [split [lindex [file split $href] end] .] 0]
				puts "$player $url_player"
				if {[file exists "data/players/$player.txt"]==0} {
					set data_player [getpage $url_player]
					save_data "data/players/$player.txt" $data_player
				}
			}
		}
	}
}

# ***************************************************************
# ***************************************************************
# ***************************************************************

set t [::struct::tree]

# ...alle Jahre
for {set i $year_begin} {$i<=$year_end} {incr i} {
	get_player_of_saison $i
}
