proc protein_spread {} {	

	# THIS PROCEDURE WILL CALCULATE THE PROTEIN PROFILE ALONG THE AXIS OF LARGEST SPREAD

	puts "				**** CALCULATING THE PROTEIN SPREAD, LOOK FOR DIR1 FILE IN THE FOLDER TO PLOT THE SPREAD ALONG THE LONGEST AXIS ****"
	puts ""

	set f [open "[lindex $::argv 0]" "r"]
	set data1 [read $f]
	close $f

	set k 0
	set minx 1000.0
	set maxx -1000.0
	set miny 1000.0
	set maxy -1000.0
	set minz 1000.0
	set maxz -1000.0

	while { $k < [llength $data1] } {
		set term [lindex $data1 $k]
		set t1 [string range $term 0 5]
		if { [lindex $data1 $k] == "ATOM" || $t1 == "HETATM" } {
			if { $t1 == "HETATM" } {
				set sterm [string length $term]
				if { $sterm > 6 } {
					set shift 1
				} else {
						set shift 0
				}
			} else { 
					set shift 0
			}
		
			set atype [lindex $data1 [expr { $k + 2 - $shift}]]
			set satype [string length $atype]

			if { $satype > 5} {
				set shift2 1
			} else {
				set shift2 0
			}			

			set chain_id [lindex $data1 [expr { $k + 4 - $shift - $shift2}]]
			set schain_id [string length $chain_id]
			if { $schain_id > 1 } {
				set shift1 1
			} else { 
				set shift1 0
			}


			set x1 [lindex $data1 [expr { $k + 6 - $shift - $shift1 -$shift2}]]
			set sx1 [string length $x1]
			if { $sx1 > 8 } {
				set shift3 1
				set t 0
				while { [string range $x1 $t $t] != "." } {
						incr t
				}
				set corx [string range $x1 0 [expr { $t + 3 }]]
				set cory [string range $x1 [expr { $t + 4 }] end]
				set sx1 [string length [string range $x1 0 [expr { $t + 3 }]]]
				set y1 ""
				set sy1 8
				set scory [string length $cory]
				if { $scory > 8 } {
					set y2 $cory
					set shift4 1
					set t 0
					while { [string range $y2 $t $t] != "." } {
						incr t
					}
					set cory [string range $y2 0 [expr { $t + 3 }]]
					set corz [string range $y2 [expr { $t + 4 }] end]
					set sy1 [string length [string range $y2 0 [expr { $t + 3 }]]]
					set z1 ""
					set sz1 8
				} else {
					set shift4 0
					set z1 [lindex $data1 [expr { $k + 8 - $shift -$shift1 - $shift2 - $shift3 - $shift4}]] 
					set z1 [format "%.3f" [expr { $z1 - 0.0 }]]
					set corz $z1
					set sz1 [string length $z1]
				}
			} else { 
				set shift3 0
				set x1 [format "%.3f" [expr { $x1 - 0.0 }]]
				set corx $x1
				set sx1 [string length $x1]
				set y1 [lindex $data1 [expr { $k + 7 - $shift -$shift1 - $shift2 - $shift3}]]
				set cory $y1 
				set sy1 [string length $y1]
				if { $sy1 > 8 } {
					set shift4 1
					set t 0
					while { [string range $y1 $t $t] != "." } {
						incr t
					}
					set cory [string range $y1 0 [expr { $t + 3 }]]
					set corz [string range $y1 [expr { $t + 4 }] end]
					set sy1 [string length [string range $y1 0 [expr { $t + 3 }]]]
					set z1 ""
					set sz1 8
				} else {
					set shift4 0
					set y1 [format "%.3f" [expr { $y1 - 0.0 }]]
					set cory $y1
					set sy1 [string length $y1]
					set z1 [lindex $data1 [expr { $k + 8 - $shift -$shift1 - $shift2 - $shift3 - $shift4}]] 
					set corz $z1
					set z1 [format "%.3f" [expr { $z1 - 0.0 }]]		
					set sz1 [string length $z1]
				}
			}
			if { $corx < $minx } {
				set minx $corx
			} 
			if { $cory < $miny } {
				set miny $cory
			}
			if { $corz < $minz } {	
				set minz $corz
			}
			if { $corx > $maxx } {
				set maxx $corx
			} 
			if { $cory > $maxy } {
				set maxy $cory
			}
			if { $corz > $maxz } {	
				set maxz $corz
			}
		}
		incr k
	}
	puts "			*** THE SPREAD OF THE PROTEIN ALONG X AXIS IS [expr { $maxx - $minx }] ***"
	puts "			*** THE SPREAD OF THE PROTEIN ALONG Y AXIS IS [expr { $maxy - $miny }] ***"
	puts "			*** THE SPREAD OF THE PROTEIN ALONG Z AXIS IS [expr { $maxz - $minz }] ***"
	set g [open "dummy" "w"]
	puts $g " { $minx $maxx } "
	puts $g " { $miny $maxy } "
	puts $g " { $minz $maxz } "
	puts $g " { [expr { $maxx - $minx }] [expr { $maxy - $miny }] [expr { $maxz - $minz }] }"
	close $g
}
protein_spread
