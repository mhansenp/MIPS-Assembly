.data
	length: .word 10
	nums: .word 1 2 3 4 5 6 7 8 9 10
	target: .word 11
	notfound: .asciiz "Target not found"
.text
.globl _main

_main:
	#loading addresses from data
	lui $a3 0x1001 #upper(length)
	ori $a3 $a3 0x0000 #lower(length)
	lw $s3 0($a3)

	lui $a1 0x1001 #upper(nums)
	ori $a1 $a1 0x0004 #lower(nums)

	lui $a2 0x1001 #upper(target)
	ori $a2 $a2 0x002c #lower(target)
	lw $s2 0($a2) #value of target is in $s2

	#$s0 and $s1 are left and right bounds of array
	#midpoint index is $a0
	addi $s0 $zero 0 #left index
	lw $s1 0($a3) #right index
	addi $s1 $s1 -1
	
	#if target > last value in the array, target not found
	#calculate the address of last element in array $t0 = $a1 + 4*last index 
	addi $s3 $s3 -1 #length-1 is last index
	sll $t0 $s3 2 # multiply by 4 because array of words
	add $t0 $t0 $a1 #add to address of first element in nums
	lw $t0 0($t0) #$t0 is now the value of the last element in array
	slt $t0 $t0 $s2 # compare target
	addi $t1 $zero 1 #1 for beq comparison
	beq $t0 $t1 print_string #if target bigger, jump to print message
while:
	slt $t0 $s0 $s1 #if left index < right index, $t0 = 1
	beq $t0 $zero end_while #exit loop if $t0 = 1
	#calculating the midpoint index
	sub $a0 $s1 $s0 #right index - left
	sra $a0 $a0 1 #divide by 2
	add $a0 $a0 $s0 # + left index
	#calculate address of midpoint $t1 = $a1 + 4*$a0
	sll $t1 $a0 2 #multiply by 4 because array of words
	add $t1 $t1 $a1 #add to address of first element in nums
	lw $t2 0($t1) #load value at midpoint into $t2
	beq $s2 $t2 end_while #if target is at midpoint, end loop
	slt $t0 $t2 $s2 #if arr(mid) < target, $t0 = 1
	beq $t0 $zero else #value at mid is greater than target
	#ignore left half of array
	addi $s0 $a0 1 #left index = midpoint index + 1
	j while
else: 	#ignore right half of array
	addi $s1 $a0 -1 #right index = midpoint index - 1
	j while
end_while:
	bne $s0 $s1 print_int 	#if left and right index are the same, value at that index is the target
	add $a0 $s0 $zero	#if jumped to end_while because left index was not smaller than
				#right index, the left index is where the target is	     
print_int:
	addi $v0 $zero 1 #command for syscall to print integer in $a0
	syscall
	j end
print_string:
	#load address of string into $a0
	lui $a0 0x1001 #upper(notfound)
	ori $a0 $a0 0x0030 #lower(notfound)
	addi $v0 $zero 4 #command for syscall to print string at address in $a0
	syscall
end:

