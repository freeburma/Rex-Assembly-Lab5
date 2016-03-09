
.text               
.global main
main: 
        
       
        
        # Job for PCB1
        
               
        # Setup interrupts                                      *** DONE
timer: 
        # Clearing the old interrupts of Timer IE Acknowledge Reg
        sw      $0, 0x72003 ($0)
        sw      $0, 0x72000 ($0)
        
        addi    $13, $0, 24                   # Timer 100 times/Second
        
        sw      $13, 0x72001 ($0) 
        addi    $13, $0, 0x3
        sw      $13, 0x72000 ($0)
        
        # Go to the first task 
        # Loading the current job address
	sw      $13, currentJob ($0)

 
        # Check with exception occured.
ExceptionControl: 
	# Set up $evec (Where we jump to when an exception occurs)
	movsg $1, $evec			# Retrieve the old handler's address
	sw $1, OLD_HANDLER($0)	        # Save it to memory - Currently it's nothing
	
	la $1, handler			# Get our new handler's address
	movgs $evec, $1			# Tell the CPU to use this new address to handle exceptions
	        
	
	# Set up $cctrl (Which interrupts we care about)
	addi $1, $0, 0x04A		#IRQ1 on, KU on (Kernel Mode), IE on
	movgs $cctrl, $1	
	
	
	
task1:  
        lw      $1, secCount ($0)
        subui   $sp, $sp, 1
       
        
        sw      $1, 0 ($sp)
        
        #jal     ssdout
        jal     time
        
        addui   $sp, $sp, 1
        j       task1

ssdout : 
      # Reserve stack space and store current/old vlaues 
      subui       $sp, $sp, 3
      sw          $2,   1 ($sp)
      sw          $ra,  2 ($sp)      
      
      # Load to $2 the first argument and get remainder 
      lw    $2, 3 ($sp) 
      remi  $2, $2, 256       # 256 values, 00 - FF
      
      
      # Display remainder to SSD
     sw      $2,     0x73003($0)     # display to the right SSD  
     srli    $2,     $2,     4       # shift to the right 4 times
     sw      $2,     0x73002($0)     # display to the left SSD
    
      # Restore values and jump to $ra
      lw    $ra, 2 ($sp)
      lw    $2,  1 ($sp)
      addui $sp, $sp, 3 
      jr    $ra        	
        
        # It it is the timer interrupt then we jump to handle_interrupt.
handler:
	# Why are we here?
	movsg $13, $estat		#Load status register
	
	andi $13, $13, 0xFFB0	        #If IRQ2 is the only bit set
	beqz $13, counter	        #Branch to our sp2_handler
	
	lw $13, OLD_HANDLER($0)	        #Else load the old handler's address
	jr $13	

     
counter: 
        lw      $13, count ($0)
        addi    $13, $13, 1               # Count ++
        sw      $13, count ($0)
        
        divi    $13, $13, 100
        sw      $13, secCount ($0)
        
        sw      $0, 0x72003 ($0)
        lw      $13, timeCountDown ($0)
        subi    $13, $13, 1
        sw      $13, timeCountDown ($0)
        
        seqi    $13, $13, 0
        bnez    $13, dispatcher
        rfe
        
 dispatcher: 
        lw      $13, currentJob ($0)
       
     
       
       
        
      
       

Restore : 
        rfe
       
       
        
.data
                      
       OLD_HANDLER:  
                       .word 0         

      currentJob : 
                .word 0     
      
      timeCountDown : 
                      .word  100   
      count : 
                        .word 0       
                        
      secCount : 
                .word 0                             
                                   
