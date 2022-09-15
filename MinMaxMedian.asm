.data
length: .word 10
nums: .word 92, 31, 92, 6, 54, 54, 62, 33, 8, 52
min: .word 0
max: .word 0
median: .word 0
	
	.text
	#Access .data section
	lui 	$at, 4097
	ori 	$a0, $at, 4 		# a0 = address of nums[0]
	ori 	$t0, $at, 0		# t0 = address of length
	#ori 	$s0, $at, 44		# Loads address of sorted[0] into s0
	
	lw	$t0, 0($t0)		# t0 = length (Fetched from memory using length address)
	sll	$t0, $t0, 2		# Convert length to length in bytes (x4)
	add	$a1, $a0, $t0		# Calculate the array end address
	jal	split		# Call the merge sort function
  	beq	$zero, $zero, getvals	# We are finished sorting

split:
	addi	$sp, $sp, -16		# Adjust stack pointer to make space for return, sublist start, end, and midpoint addresses
	sw	$ra, 0($sp)		# Save return address
	sw	$a0, 4($sp)		# Save sublist startpoint
	sw	$a1, 8($sp)		# Save sublist endpoint

	# If the array is sorted (contains only a single element), end recursion
	sub 	$t0, $a1, $a0		# Calculate the difference between the start and end address (i.e. number of elements * 4)
	slti 	$at, $t0, 8 		# if(nums[end] - nums[start] < 8 bytes){
	bne 	$at, $zero,  splitreturn # break;}
	
	# Split array by first dividing by 8, then multiplying by 4. This way, the length is divided in half, and rounded to a whole byte.
	srl	$t0, $t0, 3		# t0 = t0/8
	sll	$t0, $t0, 2		# t0 = t0*4
	add	$a1, $a0, $t0		# midpoint address a1 = a0 + t0 (start address + lengt/2 in bytes)
	sw	$a1, 12($sp)		# Save sublist midpoint to stack
	
	jal	split			# Recursive call to split first half. a1 is the midpoint of original list, but will become endpoint of new sublist
	
	lw	$a0, 12($sp)		# Load the midpoint which was saved before recursive call on first half
	lw	$a1, 8($sp)		# Load the endpoint which was saved at beginning of function, before recursive call on first half
	jal	split			# Call recursively on the second half of the array. a0 is address of midpoint of original list, and a1 is end. 
	
	# Reload original (i.e. from beginning of current call to split) start, middle, and end addresses before returning 
	lw	$a0, 4($sp)		
	lw	$a1, 12($sp)		
	lw	$a2, 8($sp)		
	
	jal	merge			# Merge the two array halves
	
# Restore sp and return to calling function
splitreturn:				

	lw	$ra, 0($sp)		# Load the return address from the stack
	addi	$sp, $sp, 16		# Restore stack pointer
	jr	$ra			# Return 
	
# Merge two sublists into one. 
merge:
	addi	$sp, $sp, -16		# Create space on stack for return, start, mid, and end addresses
	sw	$ra, 0($sp)		
	sw	$a0, 4($sp)		
	sw	$a1, 8($sp)		
	sw	$a2, 12($sp)		
	
	# Copy addresses
	add	$s0, $a0, $zero		# Copy of sublist 1 startpoint
	add	$s1, $a1, $zero		# Copy of sublist 2 startpoint (list 1 endpoint)
loop1:
	# Fetch values at start point of each sublist
	lw	$t0, 0($s0)		
	lw	$t1, 0($s1)		

	
	# Compare values to check if sublists are already in correct order
	slt 	$at, $t0, $t1
	bne 	$at, $zero, skip
	
	# If not ordered correctly
	add	$a0, $s1, $zero		# Load the argument for the element to move
	add	$a1, $s0, $zero		# Load the argument for the address to move it to
	jal	swap			# Shift the element to the new position 
	
	addi	$s1, $s1, 4		# Index next element of 2nd sublist
skip:
	addi	$s0, $s0, 4		# Index next element of 1st sublist.
	
	lw	$a2, 12($sp)		# Reload the end address

	# Check if sorted and break loop
	slt	$at, $s0, $a2 	# Sublist 1 sorted
	beq	$at, $zero, endloop
	slt	$at, $s1, $a2	# Sublist 2 sorted
	beq	$at, $zero, endloop

	# If unsorted, reiterate
	beq	$zero, $zero, loop1
	
endloop:
	
	lw	$ra, 0($sp)		# Load the return address
	addi	$sp, $sp, 16		# Adjust the stack pointer
	jr 	$ra			# Return

# Continually swaps an element with the one at the previous address, until reaching a desired address
swap:
	addi	$t0, $zero, 10 #Set t0 = 10 #Redundant????????????
	
	# Check if addresses match and break the loop
	slt 	$at, $a1, $a0
	beq 	$at, $zero, swapdone

	addi	$t6, $a0, -4		# Find the previous address in the array
	lw	$t7, 0($a0)		# Get the current pointer
	lw	$t8, 0($t6)		# Get the previous pointer
	sw	$t7, 0($t6)		# Save the current pointer to the previous address
	sw	$t8, 0($a0)		# Save the previous pointer to the current address
	add	$a0, $t6, $zero		# Shift the current position back
	beq	$zero, $zero, swap	# Loop again
swapdone:
	jr	$ra			# Return

getvals:
	lui	$at, 4097

	ori	$a0, $at, 4		# Get address of nums[0] (min value)
	ori	$t0, $at, 0		# Get address of length
	lw 	$t0, 0($t0)		# Get value of length
	sll	$t0, $t0, 2		# Multiply length by 4 to get length in bytes
	
	# Get minimum (=t7)
	lw	$t7, 0($a0)		# Minimum value stored in t7 	
	sw	$t7, 44($at)		# Store min value into predefined space
	
	# Get Maximum (=t6)
	add	$t6, $a0, $t0		# Add length to start address to get last element + 1
	addi	$t6, $t6, -4		# Subtract one index for last element
	lw	$t6, 0($t6)		# Get last element
	sw	$t6, 48($at)		# Store max value into predefined space

	# Get median (=t5)
	srl 	$t5, $t0, 1		# Divide length by 2
	add	$t5, $a0, $t5		# Get midpoint by taking start address + length/2
	lw	$t5, 0($t5)		# Get median value
	sw	$t5, 52($at)		# Store median value into predefined space

	beq 	$zero, $zero, printvals # Call to print calculated values

	.data
minstr: .asciiz "Min Value: "
maxstr: .asciiz "Max Value: "
medstr: .asciiz "Median Value: "
nline: 	.asciiz "\n"
	.text

# Print out the sorted list	
printvals:
	# Reload data from stack for printing
	lui	$at, 4097
	ori	$s0, $at, 95 		# Load newline character
	ori	$s1, $at, 56		# Load min string
	ori	$s2, $at, 68		# Load max string
	ori	$s3, $at, 80		# Load median string
	
	
	addi	$v0, $zero, 4		# Set to print strings
	add	$a0, $zero, $s1		# Print min string
	syscall			
	
	addi	$v0, $zero, 1		# Set to print ints
	add	$a0, $zero, $t7		# Print min value			
	syscall
	addi	$v0, $zero, 4		# Set to print strings
	add	$a0, $zero, $s0		# New line
	syscall
	
	add	$a0, $zero, $s2 	# Print max string
	syscall			
	addi	$v0, $zero, 1		# Set to print ints
	add	$a0, $zero, $t6		# Print max value			
	syscall
	addi	$v0, $zero, 4		# Set to print strings
	add	$a0, $zero, $s0		# New line
	syscall
	
	add	$a0, $zero, $s3 	# Print Median string
	syscall		
	addi	$v0, $zero, 1		# Set to print ints	
	add	$a0, $zero, $t5		# Print Median value			
	syscall
	
	
end:						# Terminate the program
	addi	$v0,$zero, 10
	syscall