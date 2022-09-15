.data
	sizeB: .word 2,3
	matrixB: .word 5,6,7,8,9,10
	result: .word 0:9
	sizeX: .word 3,1
	matrixX: .word 1,2,3
	sizeY: .word 3,1
	matrixY: .word 3,2,1
	resultXY: .word 0:8
.text


transpose:
	#make size of Y 1,3
	lui $t0 0x1001 #load address of sizeX into $t0
	ori $t0 $t0 0x0058
	lw $t1 0($t0) #number rows in y
	lw $t2 4($t0) #number of columns in y
	sw $t2 0($t0) #switch rows and columns of y
	sw $t1 4($t0)
endtranspose:
	addi $v0 $zero 1 #printing integers with syscall
	#load things from data
	lui $t0 0x1001 #load address of sizeX into $t0
	ori $t0 $t0 0x0044
	lw $a1 0($t0) #max row
	lui $t0 0x1001 #load address of sizeY into $t0
	ori $t0 $t0 0x0058
	lw $a2 4($t0) #max column
	
	lui $s3 0x1001 #load address of resultXY into $s3
	ori $s3 $s3 0x006c
	lui $s4 0x1001 #load address of matrixX into $s4
	ori $s4 $s4 0x004c
	lui $s5 0x1001 #load address of matrixY into $s5
	ori $s5 $s5 0x0060
multiplication:
	#a1 is max row
	#a2 is max column
	#s0 is row where we are
	#s1 is column where we are
	#$t2 is value to be stored
	addi $s0 $zero 1 #start at row 1
	addi $s1 $zero 1 #start at column 1
outloop:
	addi $t1 $zero 1 #1 for comparison
	slt $t0 $a1 $s0 #if max row < current, $t0 = 1, stop 
	beq $t0 $t1 endout
	
	#calculate address of x at currrent row into $t3
	addi $t3 $s0 -1 #current row -1
	sll $t3 $t3 2 #multiply by four because words
	add $t3 $t3 $s4 #add to start of matrixX
	lw $t3 0($t3) #t3 is value at x current row
	
inloop:
	slt $t0 $a2 $s1 #if max col < current, next row 
	beq $t0 $t1 endin 
	#calculate address of y at current column into $t4
	addi $t4 $s1 -1 #current column -1
	sll $t4 $t4 2 #multiply by four because words
	add $t4 $t4 $s5 #add to start of matrixY
	lw $t4 0($t4) #t4 is value at y current col
	
	mult $t3 $t4
	mflo $a0 #t2 is result of multiplication
	sw $a0 0($s3) #load value into result
	addi $s3 $s3 4 #increment address to next spot
	syscall
	addi $s1 $s1 1 #increment current column
	j inloop
endin:
	addi $s1 $zero 1 #reset current column
	addi $s0 $s0 1 #increment current row
	j outloop
endout:
#multiplying X.Y by matrixB
	#load things from data
task2:
	lui $t0 0x1001 #load address of sizeB into $t0
	ori $t0 $t0 0x0000
	lw $a1 0($t0) #max row
	addi $a2 $zero 3 #max column
	
	lui $s3 0x1001 #load address of result into $s3
	ori $s3 $s3 0x0020
	lui $s4 0x1001 #load address of matrixB into $s4
	ori $s4 $s4 0x0008
	lui $s5 0x1001 #load address of resultXY into $s5
	ori $s5 $s5 0x006c
	
	addi $t6 $zero 3 #3 for multiplication
	addi $t1 $zero 1 #1 for comparison
multiplication2:
	#a1 is max row
	#a2 is max column
	#s0 is row where we are
	#s1 is column where we are
	#$t2 is value to be stored
	addi $s0 $zero 1 #start at row 1
	addi $s1 $zero 1 #start at column 1
outloop2:
	slt $t0 $a1 $s0 #if max row < current, $t0 = 1, stop 
	beq $t0 $t1 endout2
inloop2:
	slt $t0 $a2 $s1 #if max col < current, next row 
	beq $t0 $t1 endin2
	add $a0 $zero $zero #reset value to do math
	addi $t5 $zero 1 #start math at col 1 each time
math:
	#check col isn't greater than max col
	slt $t0 $a2 $t5 #if max < $t5, $t0 = 1, 
	beq $t0 $t1 endmath #stop adding
	#calculate index of needed value in B 
	addi $t3 $s0 -1 #current row - 1
	mult $t3 $t6 #multiply by the length of a row
	mflo $t3
	add $t3 $t3 $t5 #add current math column
	#calculate address based on index in $t3
	addi $t3 $t3 -1 #index - 1
	sll $t3 $t3 2 #multiply by 4
	add $t3 $t3 $s4 #add to the base address of matrixB
	lw $t3 0($t3) #value at that address
	
	#calculate index of needed value in result XY 
	addi $t4 $t5 -1 #current col - 1
	mult $t4 $t6 #multiply by the length of a col
	mflo $t4
	add $t4 $t4 $s1 #add current col
	#calculate address based on index in $t3
	addi $t4 $t4 -1 #index - 1
	sll $t4 $t4 2 #multiply by 4
	add $t4 $t4 $s5 #add to the base address of resultXY
	lw $t4 0($t4) #value at that address
	
	mult $t3 $t4
	mflo $t7 #t7 is result of multiplication
	add $a0 $a0 $t7
	addi $t5 $t5 1 #increment current math column
	j math
endmath:
	sw $a0 0($s3) #load value into result
	addi $s3 $s3 4 #increment address to next spot
	syscall
	addi $s1 $s1 1 #increment current column
	j inloop2
endin2:
	addi $s1 $zero 1 #reset current column
	addi $s0 $s0 1 #increment current row
	j outloop2
endout2:
