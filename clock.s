.global	time
time:
	subui	$sp, $sp, 7
	sw	$13, 1($sp)
	sw	$ra, 2($sp)
	
	lw      $13, 7 ($sp)    
	
	sw      $13, count ($0)
	
	lw      $13, count ($0)
	divi    $13, $13, 60
	sw      $13, minute ($0)
	
       
	
	lw      $13, count ($0)
	remi    $13, $13, 60
	sw      $13, second ($0)
	
	
	add     $1, $0, $0
	add     $2, $0, $0
	add     $3, $0, $0
	add     $4, $0, $0
	add     $5, $0, $0
	
addSemi:       
       
	addi    $3, $3, ':'
	
	 
	
	  
	
       
second1:             
        lw      $1, second ($0)
        remi  $1, $1, 10            # get remainder
        addi  $1, $1, 48            # add 48 to convert to ASCII
      
        
   
      
 second22:            
      # Get quotient and store as new second value 
      lw    $2, second ($0)        # laod again coutner value 
      divi  $2, $2, 10            # get qutient 
      remi  $2, $2, 10            # get remainder
      addi  $2, $2, 48            # add 48 to convert to ASCII
   

     
  

        
        


minute1:             
        lw      $4, minute ($0)
        remi  $4, $4, 10            # get remainder
        addi  $4, $4, 48            # add 48 to convert to ASCII
        
      
minute22:       
      # Get quotient and stroe as new minute value 
      lw    $5, minute ($0)        # load again counter value 
      divi  $5, $5, 10            # get quotient 
      remi  $5, $5, 10            # get remainder
      addi  $5, $5, 48            # add 48 to convert to ASCII


        

display :  
        jal         check_serial1
        add    $13, $0, $0
	addi    $13, $13, 13
        sw      $13, 0x70000 ($0)  
        
        jal     check_serial1        
        sw      $5, 0x70000 ($0)
        
        jal         check_serial1        
        sw      $4, 0x70000 ($0)
        
 
        
        jal         check_serial1        
        sw      $3, 0x70000 ($0)  
        
        jal         check_serial1       
        sw      $2, 0x70000 ($0)
     
        jal         check_serial1       
        sw      $1, 0x70000 ($0)
        

       
        
        
       
        

        
      

restore:
	lw	$13, 1($sp)
	lw	$ra, 2($sp)
	addui	$sp, $sp, 7
	
	
	jr $ra

check_serial1: 
      # Check if serial port 1 is ready to receive data 
      lw    $13, 0x70003 ($0)       # load to $13 the serial port 1 status 
      andi  $13,  $13, 0x2          # Check if TDS bit is set 
      beqz  $13, check_serial1      # if not set, then check again
      jr $ra
      


.data 
        semi : 
                .asciiz ":"
                
        count: 
                .word 0     
                
        minute: 
                .word 0
                
        second : 
                .word 0     
                
         minute2: 
                .word 0
                
        second2 : 
                .word 0       
                
                
        minute111: 
                .word 0
                
        second112 : 
                .word 0     
                
         minute221: 
                .word 0
                
        second222 : 
                .word 0     
                                         
          inc_stack_cnt : .word 0      
                
