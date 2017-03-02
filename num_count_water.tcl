proc wat_count {} {

	package require math::linearalgebra

	# tclsh num_count.tcl prmtop inpcrd sf tf fs nlipid_il nlipid_ol

	set sf [lindex $::argv 2]
	set tf [lindex $::argv 3]
	set fs [lindex $::argv 4]
	set nframes [expr { ($tf - $sf) / $fs }]
	set nlipids [expr { [lindex $::argv 5] + [lindex $::argv 6] }]

	set nul 0
	
	for {set fr $sf} {$fr < $tf} {set fr [expr { $fr + $fs }]} {

		puts "				##### FRAME $fr #####"
		
		# EXECUTING CPPTRAJ

		set in [open "input" "w"]
		puts $in "trajin [lindex $::argv 1] $fr $fr"
		puts $in "strip :PA,PC,OL"
		puts $in "trajout output.pdb"
		puts $in "go"
		puts $in "quit"
		close $in

		exec cpptraj -p [lindex $::argv 0] -i input

		set f [open "output.pdb" "r"]
		set data1 [read $f]
		close $f

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
		set atc 0
		set j 0
		while { $k < [llength $data1] } {
			puts "				#### $k OF [llength $data1] ####"
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

				set resname [lindex $data1 [expr { $k + 3 - $shift }]]

				if { $satype > 5} {
					set shift2 1
				} else {
					set shift2 0
				}
		

				#  BASED ON RADIUS
			
				if { $atype == "O" && $resname == "WAT" } {
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

					if { $r > 70.85 } {
						incr nul
					} 
				}
			}
		incr k
		}
	}
	set nul [expr { $nul / $nframes }]
	puts "					#### FINAL CONCENTRATION OUTER = $nul AND INNER = [expr { $nlipids - $nul }] ####"
}
wat_count
	
