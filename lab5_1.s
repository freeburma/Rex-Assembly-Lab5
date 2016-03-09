


.bss         
       .space 100                                  
Stack : 
        # PCB 1 Offsets 
        #.equ    nextJob,                0
        #.equ    reg1,                   1 
        #.equ    reg2,                   2
        #.equ    reg3,                   3
        #.equ    reg4,                   4
        #.equ    reg5,                   5
        #.equ    reg6,                   6
        #.equ    reg7,                   7
        #.equ    reg8,                   8
        #.equ    reg9,                   9
        #.equ    reg10,                  10
        #.equ    reg11,                  11
        #.equ    reg12,                  12
        #.equ    reg13,                  13
        #.equ    reg14,                  14
        #.equ    reg15,                  15
        #.equ    regEar,                 16
        #.equ    regCctrl,               17
        #.equ    timeSlice,              18
              
                         
.text               
.global main
main: 
        subui    $sp, $sp, 1
        sw      $1, 0 ($sp)
        
               
        # Setup interrupts                                      *** DONE
timer: 
        # Clearing the old interrupts of Timer IE Acknowledge Reg
        sw      $0, 0x72003 ($0)
        sw      $0, 0x72000 ($0)
        
        addi    $13, $0, 2400
        
        sw      $13, 0x72001 ($0) 
        addi    $13, $0, 0x3
        sw      $13, 0x72000 ($0)
        
        # Go to the first task 


 
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
	
        
        # It it is the timer interrupt then we jump to handle_interrupt.
handler:
	# Why are we here?
	movsg $13, $estat		#Load status register
	
	andi $13, $13, 0xFFB0	        #If IRQ2 is the only bit set
	beqz $13, counter	        #Branch to our sp2_handler
	
	lw $13, OLD_HANDLER($0)	        #Else load the old handler's address
	jr $13	


counter: 
        
        addui    $1, $1, 1               # Count ++
        sw      $1, 0 ($sp)
        
        
        
callTime: 
        jal time                        # Calling times.o object files
       



        
          # Acknowledge the interrupt
        sw      $0, 0x72003 ($0)
        rfe 
        
.data
#current_job_add:
              #.word 
                
#        timeCountDown : 
#                        .word 
       OLD_HANDLER:  
                       .word 0          
