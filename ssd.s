.text
.global ssd
ssd: 
loadSwitches:
	lw $2, 0x73000 ($0)             # loading the switches values 
	sw      $2, 0x73003 ($0)	
	
	srli $2, $2, 4
	sw $2, 0x73002($0)		# Store the values in left SSD
	
	j loadSwitches
