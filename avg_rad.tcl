set f [open "variable" "r"]
set data [read $f]
close $f

set g [open "inner_leaflet" "r"]
set data1 [read $g]
close $g

set k 0
set ulr 0.0
set llr 0.0

while { $k < [llength $data] } {
	set t1 [lindex $data $k]
	set t1 [expr { ($t1 * 3) - 1 }]
	set t2 [lindex $data [expr { $k + 1}]]

	set k1 1
	set count 0

	while { $k1 < [llength $data1] } {
		if { [lindex $data1 $k1] == $t1 } {
			incr count 
			set k1 [llength $data1]
		}
		incr k1
	}

	if { $count == 0 } {
		set ulr [expr { $ulr + $t2 }]
		incr nu
	} else {
		set llr [expr { $llr + $t2 }]
		incr nl
	}

	incr k 2
}
puts "$nu $nl"
set ulr [expr { $ulr / $nu }]
set llr [expr { $llr / $nl }]

puts "				#### RADIUS OUTER P31'S = $ulr AND RADIUS INNER P31'S = $llr ####"


