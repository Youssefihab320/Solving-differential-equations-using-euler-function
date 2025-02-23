#Project
.text
main:
	lw $s0, 0($a1)		#adress of y(0)
	lw $s1, 4($a1)		#adress of h
	lw $s2, 8($a1)		#adress of steps
	
	lb $s3, 0($s0)		#$s3 = y(0)
	lb $s4, 0($s1)		#$s4 = h
	lb $s5, 0($s2)		#$s5 = no. of steps
	addi $s3,$s3,-48
	addi $s4,$s4,-48
	addi $s5,$s5,-48
	
	jal euler_fn
	lui $t0,0x1001		#store result at memory adress 0x10010000
	sw $v0,0($t0)
	j exit
	
euler_fn:
	addi $sp,$sp,-16
	sw $ra,0($sp)
	sw $s3,4($sp)
	sw $s4,8($sp)
	sw $s5,12($sp)
	
	addi $t0,$0,0		#intialize step counter
	addi $t1,$0,0		#x_0 = 0 
	addi $t2,$0,0		#y' = 0
		
solve_ode_loop:
	slt $at,$t0,$s5
	beq $at,$0,solve_ode_done
	
	addi $a0,$t1,0
	addi $a1,$t1,0
	jal multiply_fn		#v0 = x^2
	addi $a0,$0,260		#a0 = 260	
	addi $a1,$v0,0		#a1 = v0
	jal multiply_fn		#v0 = 260*x^2
	sub $t2,$0,$v0		#t2 = y' = -260*x^2
	addi $a0,$0,83		#a0 = 83
	addi $a1,$t1,0		#a1 = x_0 	
	jal multiply_fn
	add $t2,$t2,$v0		#t2 = y' = -260*x^2 + 83*x
	addi $a0,$s3,0		#a0 = y(0)
	jal power3
	addi $a0,$0,591
	addi $a1,$v0,0
	jal multiply_fn		#v0 = 591 * y^3
	sub $t2,$t2,$v0 		#t2 = y' = -260*x2 + 83x - 591*y^3
	addi $a0,$s3,0
	addi $a1,$s3,0
	jal multiply_fn		#v0 = y^2
	addi $a0,$0,92
	addi $a1,$v0,0
	jal multiply_fn		#v0 = 92*y^2
	add $t2,$t2,$v0		#t2 = y' = -260*x^2 + 83x - 591*y^3 + 92*y^2
	addi $a0,$0,55
	addi $a1,$s3,0
	jal multiply_fn		#v0 = 55*y
	sub $t2,$t2,$v0		#t2=y'=-260*x^2+83x - 591*y^3 + 92*y^2 - 55y
	addi $t2,$t2,-70		#t2=y'=-260*x^2+83x-591*y^3+92*y^2-55y-70
	
	add $t1,$t1,$s4		#x_0 = x_0 + h
	addi $a0,$s4,0		#a0 = h
	addi $a1,$t2,0		#a1 = y'
	jal multiply_fn		#v0 = h*y'
	add $s3,$s3,$v0		#y(0) = y(0) + v0 = y(0) + h*y'
	addi $t0,$t0,1
	j solve_ode_loop
	
solve_ode_done:
	addi $v0,$s3,0		#v0 = y(0) final 
	
	lw $s5,12($sp)
	lw $s4,8($sp)
	lw $s3,4($sp)
	lw $ra,0($sp)
	addi $sp,$sp,16
	jr $ra

power3:
	addi $a0,$a0,0		#a0 = variable
	addi $t7,$a0,0
	srl $at,$a0,31		#condition to check if number is negative
	beq $at,$0,cont
	sub $a0,$0,$a0
cont:	addi $a1,$a0,0		#a1 = a0 = variable
        addi $v0,$0,0		#intialization 'result = 0'
        addi $sp,$sp,-8
        sw $ra,0($sp)		#store ra bec it will be changed in mul
        sw $a0,4($sp)		#store a0 bec it will be changed in mul 
        jal multiply_fn		#v0 = variable ^ 2		
        addi $a1,$v0,0		#a1 = v0
        lw $a0,4($sp)		#restore a0 from stack 
	jal multiply_fn		#v0 = variable ^ 2 * variable
	lw $ra,0($sp)       
	addi $sp,$sp,8
	srl $at,$t7,31		#condition to check if number is negative
	beq $at,$0,finish
	sub $v0,$0,$v0
finish:	jr $ra
		
multiply_fn:
     	addi $a1,$a1,0		#a1 = variable
        addi $a0,$a0,0		#a0 = coeff of variable
        addi $v0,$0,0		#intialization 'result = 0'
        srl $at,$a0,31		#condition to check if variable was negataive
    	beq $at,$0,multiply_loop_pos
    	sub $a0,$0,$a0
    	j multiply_loop_neg
    	
multiply_loop_pos:
	beq $a0, $zero, multiply_done_pos
        add $v0, $v0, $a1
        addi $a0, $a0, -1
        j multiply_loop_pos
        
multiply_loop_neg:
	beq $a0, $zero, multiply_done_neg
        add $v0, $v0, $a1
        addi $a0, $a0, -1
        j multiply_loop_neg

multiply_done_neg:
    	sub $v0,$0,$v0
multiply_done_pos:
	jr $ra
    exit: