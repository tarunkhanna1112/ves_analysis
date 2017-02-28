proc lip_count {} {

	# tclsh num_count.tcl prmtop inpcrd sf tf fs nlipid_il nlipid_ol

	set sf [lindex $::argv 2]
	set tf [lindex $::argv 3]
	set fs [lindex $::argv 4]
	set nlipids [expr { [lindex $::argv 5] + [lindex $::argv 6] }]
	set nlipids [expr { $nlipids * 3 }]

	set h [open "reslist" "w"]
	
	for {set fr $sf} {$fr < $tf} {set fr [expr { $fr + $fs }]} {

		puts "				##### FRAME $fr #####"
		
		# EXECUTING CPPTRAJ

		set in [open "input" "w"]
		puts $in "trajin [lindex $::argv 1] $fr $fr"
		puts $in "strip !:PA,PC,OL"
		puts $in "trajout output.pdb"
		puts $in "go"
		puts $in "quit"
		close $in

		exec cpptraj -p [lindex $::argv 0] -i input

		set reslistul ""
		set nul 0
		set rc -1
		set reslistll ""
		set nll 0


		set f [open "output.pdb" "r"]
		set data1 [read $f]
		close $f

		set g [open "radius" "w"]

		# ASSUMING CPPTRAJ GENERATES THE CRYTAL INFO

		if { [lindex $data1 0] != "CRYST1" } {
			exit
		} else {
			puts "				#### BOX INFO FOUND #### "
		}
		set xshift [expr { [lindex $data1 1] / 2.0 }]
		set yshift [expr { [lindex $data1 2] / 2.0 }]
		set zshift [expr { [lindex $data1 3] / 2.0 }]

		set k 0
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
				if { $atype == "O21" } {
					set res_id [lindex $data1 [expr { $k + 4 - $shift - $shift2}]]
					set sres_id [string length $res_id]
				
					set shift1 0
			
					set x1 [lindex $data1 [expr { $k + 5 - $shift - $shift1 -$shift2}]]
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
							set z1 [lindex $data1 [expr { $k + 7 - $shift -$shift1 - $shift2 - $shift3 - $shift4}]] 
							set z1 [format "%.3f" [expr { $z1 - 0.0 }]]
							set corz $z1
							set sz1 [string length $z1]
						}
					} else { 
						set shift3 0
						set x1 [format "%.3f" [expr { $x1 - 0.0 }]]
						set corx $x1
						set sx1 [string length $x1]
						set y1 [lindex $data1 [expr { $k + 6 - $shift -$shift1 - $shift2 - $shift3}]]
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
							set z1 [lindex $data1 [expr { $k + 7 - $shift -$shift1 - $shift2 - $shift3 - $shift4}]] 
							set corz $z1
							set z1 [format "%.3f" [expr { $z1 - 0.0 }]]		
							set sz1 [string length $z1]
						}
					}

					set corx [expr { $corx - $xshift }]
					set cory [expr { $cory - $yshift }]
					set corz [expr { $corz - $zshift }]

					set r [expr { ($corx*$corx) + ($cory*$cory) + ($corz*$corz) }]
					set r [expr { sqrt($r) }]
					puts $g "$r"

					if { $rc == -1 } {
						set rc $r
					}
					if { $r > [expr { $rc - 15 }] && $r < [expr { $rc + 15 }] } {
						set reslistul [linsert $reslistul $nul [expr { $res_id - 1 }]]
						incr nul
						set reslistul [linsert $reslistul $nul $res_id]
						incr nul
						set reslistul [linsert $reslistul $nul [expr { $res_id + 1 }]]
						incr nul
					} 
				}			
			}
		incr k
		}
		# INNER LEAFLET
		for {set i 1} {$i <= $nlipids} {incr i} {
			set lip $i
			set count 0
			set k 0
			while { $k < [llength $reslistul] } {
				if { $lip == [lindex $reslistul $k] } {
					incr count
				}
				incr k
			}
			if { $count == 0 } {
				set reslistll [linsert $reslistll $nll $lip]
				incr nll
			}
		}
		#puts $h "outer"
		#puts $h "\{$fr $nul\}"
		puts $h "\{$reslistul\}"
		#puts $h "inner"
		#puts $h "\{$fr $nll\}"
		puts $h "\{$reslistll\}"
		close $g
	}
	close $h
	
	# DETERMING THE FINAL RESIDUE LIST AS WELL AS THE LIST OF FLIPPED LIPIDS
	
	set m [open "reslist" "r"]
	set reslistul [read $m]
	close $m

	set h1 [open "outer_leaflet" "w"]
	set h2 [open "inner_leaflet" "w"]
	set h3 [open "outer_leaflet_flipped" "w"]
	set h4 [open "inner_leaflet_flipped" "w"]
	set nil 0
	set nol 0
	set reslistol ""
	set reslistil ""
	set nilf 0
	set nolf 0
	set reslistolf ""
	set reslistilf ""
	puts ""
	for {set i 1} {$i <= $nlipids} {incr i} {
		# CHECKING OUTER LEAFLET
		set k 0
		set countol 0
		while { $k < [llength $reslistul] } {
			set k1 0
			while { $k1 < [llength [lindex $reslistul $k]] } {
				if { $i == [lindex $reslistul $k $k1] } {
					incr countol
					set k1 [llength [lindex $reslistul $k]]
				}
				incr k1
			}
			incr k 2
		}
		# CHECKING INNER LEAFLET
		set k 1
		set countil 0
		while { $k < [llength $reslistul] } {
			set k1 0
			while { $k1 < [llength [lindex $reslistul $k]] } {
				if { $i == [lindex $reslistul $k $k1] } {
					incr countil
					set k1 [llength [lindex $reslistul $k]]
				}
				incr k1
			}
			incr k 2
		}

		if { $countol > $countil } {
			if { $countil != 0 } {
				puts "				#### RES $i BELONGS TO OUTER LEAFLET BY [expr { ($countol * 100) / $countil }] PERCENT ####"
			} else { 
				puts "				#### RES $i BELONGS TO OUTER LEAFLET BY 100 PERCENT ####"
			}
			set reslistol [linsert $reslistol $nol $i]
			incr nol
			if { $i > [expr { 3 * [lindex $::argv 6] }] } {
				set reslistilf [linsert $reslistilf $nilf $i]
				incr nilf
			}
		} else {
			if { $countol != 0 } {
				puts "				#### RES $i BELONGS TO INNER LEAFLET BY [expr { ($countil * 100) / $countol }] PERCENT ####"
			} else { 
				puts "				#### RES $i BELONGS TO INNER LEAFLET BY 100 PERCENT ####"
			}
			set reslistil [linsert $reslistil $nil $i]
			incr nil
			if { $i < [expr { 3 * [lindex $::argv 6] }] } {
				set reslistolf [linsert $reslistolf $nolf $i]
				incr nolf
			}
		}
	}
	puts $h1 "[expr  { $nol / 3 }]"
	puts $h1 "$reslistol"
	puts $h2 "[expr  { $nil / 3 }]"
	puts $h2 "$reslistil"	
	puts $h3 "[expr  { $nolf / 3 }]"
	puts $h3 "$reslistolf"
	puts $h4 "[expr  { $nilf / 3 }]"
	puts $h4 "$reslistilf"	
	close $h1
	close $h2
	close $h3
	close $h4
}
lip_count
	
