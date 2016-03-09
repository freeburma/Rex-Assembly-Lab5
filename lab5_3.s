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

.bss        
        
pcb1:         
        .space 20
stack1:    
     .space 100
        # PCB Offsets
        .equ    NEXT_TASK,  0               # PCB block address of next task
        .equ    reg1,      1
        .equ    reg2,      2
        .equ    reg3,      3
        .equ    reg4,      4
        .equ    reg5,      5
        .equ    reg6,      6
        .equ    reg7,      7
        .equ    reg8,      8
        .equ    reg9,      9
        .equ    reg10,     10
        .equ    reg11,     11
        .equ    reg12,     12
        .equ    reg13,     13
        .equ    reg14,     14
        .equ    reg15,     15
        .equ    regEar,    16
        .equ    regCctrl,  17
        .equ    TIME_SLICE, 18    
     
.text               
.global main
main:        
        
        # Job for PCB1
        la      $1,     pcb1            # loading the pcb1
        la      $13,    pcb1            # load the next task (currently it still have one)
        sw      $13,    NEXT_TASK ($1)
        
        # Initialize the pcb offsets 
        la      $13, stack1
        sw      $13, reg14 ($1)         # Stroing the value in offset 14
        
        # Go to the first task 
        la      $13, task1
        sw      $13, regEar ($1)
        
        # initialize job1 time slice
        addi    $13, $0, 0
        sw      $13, TIME_SLICE($1)
        
        # Setup interrupts                                      *** DONE        

        # Check with exception occured.
ExceptionControl: 
	# Set up $evec (Where we jump to when an exception occurs)
	movsg $13, $evec			# Retrieve the old handler's address
	sw $13, OLD_HANDLER($0)	        # Save it to memory - Currently it's nothing
	
	la $13, handler			# Get our new handler's address
	movgs $evec, $13			# Tell the CPU to use this new address to handle exceptions
	# Set up $cctrl (Which interrupts we care about)
	addi $13, $0, 0x04A		#IRQ1 on, KU on (Kernel Mode), IE on
	movgs $cctrl, $13	        
timer: 
        # Clearing the old interrupts of Timer IE Acknowledge Reg
        sw      $0, 0x72003 ($0)
        sw      $0, 0x72000 ($0)
        
        addi    $13, $0, 24                   # Timer 100 times/Second
        
        sw      $13, 0x72001 ($0) 
        addi    $13, $0, 0x3
        sw      $13, 0x72000 ($0)
        
   
        # Loading the current job address
        la      $13, pcb1
	sw      $13, currentJob ($0)
	
	j       restoringReg
	
	
	
	
	
task1:  
        lw      $1, secCount ($0)
        subui   $sp, $sp, 1
       
        
        sw      $1, 0 ($sp)
        
        #jal     ssdout
        jal     time
        
        addui   $sp, $sp, 1
        j       task1


        
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
       
backupReg: 
        # PCB Offsets
        
        sw    $1,       reg1 ($13)
        sw    $2,       reg2 ($13)
        sw    $3,       reg3 ($13)
        sw    $4,       reg4 ($13)
        sw    $5,       reg5 ($13)
        sw    $6,       reg6 ($13)
        sw    $7,       reg7 ($13)
        sw    $8,       reg8 ($13)
        sw    $9,       reg9 ($13)
        sw    $10,      reg10 ($13)
        sw    $11,      reg11 ($13)
        sw    $12,      reg12 ($13)
        sw    $13,      reg13 ($13)
        sw    $14,      reg14 ($13)
        sw    $15,      reg15 ($13)
                
backupSpecialReg: 
        movsg   $3, $ers
        sw      $3, reg13 ($13)
        
        movsg   $3, $ear 
        sw      $3, regEar ($13)
        
        movsg   $3, $cctrl
        sw      $3, regCctrl ($13) 
        
        # Changing to next task
        lw      $13, NEXT_TASK ($13)
        sw      $13, currentJob ($0)
        
restoringReg: 
        lw      $3, reg13 ($13)        
        movgs   $ers, $3
        
        
        lw      $3, regEar ($13)
        movgs   $ear, $3
        
        lw      $3, regCctrl ($13)
        movgs   $cctrl, $3
        
        lw      $3, TIME_SLICE ($13)
        sw      $3, timeCountDown ($0)
        
        lw    $1,       reg1 ($13)
        lw    $2,       reg2 ($13)
        lw    $3,       reg3 ($13)
        lw    $4,       reg4 ($13)
        lw    $5,       reg5 ($13)
        lw    $6,       reg6 ($13)
        lw    $7,       reg7 ($13)
        lw    $8,       reg8 ($13)
        lw    $9,       reg9 ($13)
        lw    $10,      reg10 ($13)
        lw    $11,      reg11 ($13)
        lw    $12,      reg12 ($13)
        lw    $13,      reg13 ($13)
        lw    $14,      reg14 ($13)
        lw    $15,      reg15 ($13)
       
   
        rfe
       
       
        
         
                                   
