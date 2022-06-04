#####################################################################
#
# CSC258H5S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Student: Andrew Hanzhuo Zhang, 1006974525
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission? 
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# 5
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Display the number of lives remaining.
# 2. Restart the game if the “retry” option is chosen. (click "r").
# 3. Dynamic increase in difficulty. (Increase in speed)
# 4. Make objects look more like the arcade version.
# 5. Have objects in different rows move at different speeds.
# 6. Display death/respawn animation each time player loses a frog.
# 7. Make the frog point in the direction that it's travelling.
# 8. Add sound effects for movement, losing lives, and reaching the goal.
# 9. Pause the game when "p" is pressed and resume when "p" is pressed again.
# 10. Press "q" to quit and "r" to retry any time in the game except when paused.
#
#
#####################################################################

.data
displayAddress: .word 0x10008000

.text
main: 
	lw $t0, displayAddress # $t0 stores the base address for display
	
	li $a0, 73 #Starting buzz
	li $a1, 1000
	li $a2, 104
	li $a3, 127
	li $v0, 31
	syscall
	
	li $a2, 0x000078 # Render finish line
	li $a1, 0
	jal setHBar
	li $a2, 0x00d9ab
	li $a0, 2
	li $a1, 0
	jal setSquare
	li $a0, 10
	li $a1, 0
	jal setSquare
	li $a0, 18
	li $a1, 0
	jal setSquare
	li $a0, 26
	li $a1, 0
	jal setSquare
	
	li $s2, 3
	li $s3, 0
	
	newGame:
	
	jal setBkgd
	jal setLife
	
	li $s0, 14
	li $s1, 24
	move $a0, $s0
	move $a1, $s1
	jal storeCache
	
	li $a2, 0x266b00
	jal setFrog
	
	li $a0, 500 # Spawn Animation
	li $v0, 32
	syscall
	
	
	move $a0, $s0
	move $a1, $s1
	li $a2, 0x15b139
	jal setFrog
	
	li $a0, 21
	li $a1, 20
	jal setCar1
	
	li $a0, 5
	li $a1, 20
	jal setCar1
	
	li $a0, 14
	li $a1, 16
	jal setCar2
	
	li $a0, 8
	li $a1, 8
	jal setLog1
	
	li $a0, 0
	li $a1, 4
	jal setLog2
	
	li $a0, 16
	li $a1, 4
	jal setLog2
	
	li $s7,0
	
	Animate:
		# Accept keyboard input
		move $t8, $ra
		addi, $s7, $s7, 1 # Frame counter

		lw $v0, 0xffff0000
		beqz $v0, NoKey
		lw $v0, 0xffff0004
		li $v1, 0x70
		beq $v0, $v1, pause
		resume:
		li $v1, 0x71
		beq $v0, $v1, Exit
		li $v1, 0x72
		beq $v0, $v1, main
		li $v1, 0x61
		bne $v0, $v1, respondw
		responda:
			jal respondA
			j NoKey
		
		respondw:
			li $v1, 0x77
			bne $v0, $v1, respondd
			jal respondW
			j NoKey
			
		respondd:
			li $v1, 0x64
			bne $v0, $v1, responds
			jal respondD
			j NoKey
			
		responds:
			li $v1, 0x73
			bne $v0, $v1, NoKey
			jal respondS
			j NoKey

		NoKey:
		
		li $t1, 12
		sub $t1, $t1, $s3
		sub $t1, $t1, $s3
		sub $t1, $t1, $s3
		div $s7, $t1
		mfhi, $t1
		beq $zero, $t1, MoveDiv12
		MovedDiv12:
		
		li $t1, 8
		sub $t1, $t1, $s3
		sub $t1, $t1, $s3
		div $s7, $t1
		mfhi, $t1
		beq $zero, $t1, MoveDiv8
		MovedDiv8:
		
		li $t1, 4
		sub $t1, $t1, $s3
		div $s7, $t1
		mfhi, $t1
		beq $zero, $t1, MoveDiv4
		MovedDiv4:
		
		li $a0, 30
		li $v0, 32
		syscall
		
		j Animate
		
		MoveDiv12:
			jal moveCar1
			jal correctFrogCar1
			
			jal moveLog1
			jal correctFrogLog1
			j MovedDiv12
		
		MoveDiv8:
			jal moveLog2
			jal correctFrogLog2
			j MovedDiv8
		
		MoveDiv4:
			jal moveCar2
			jal correctFrogCar2
			j MovedDiv4
		
	j Exit




correctFrogCar1:
	move $t8, $ra
	
	li $v0, 20
	bne, $s1, $v0, correctFrogCar1Return

	# Rerender previous location
	move $a1, $s1
	addi $a0, $s0, 1
	jal loadCache
	
	move $a1, $s1
	move $a0, $s0
	
	# Check if frog is dead
	jal checkDeathRoad
	jal checkDeathRiver
	
	# Cache new location
	jal storeCache
	
	move $a1, $s1
	move $a0, $s0
	li $a2, 0x15b139
	jal setFrog
	
	correctFrogCar1Return:
		move $ra, $t8
		jr $ra
	

correctFrogCar2:
	move $t8, $ra
	
	li $v0, 16
	bne, $s1, $v0, correctFrogCar2Return

	# Rerender previous location
	move $a1, $s1
	addi $a0, $s0, -1
	jal loadCache
	
	move $a1, $s1
	move $a0, $s0
	
	# Check if frog is dead
	jal checkDeathRoad
	
	# Cache new location
	jal storeCache
	
	move $a1, $s1
	move $a0, $s0
	li $a2, 0x15b139
	jal setFrog
	
	correctFrogCar2Return:
		move $ra, $t8
		jr $ra

correctFrogLog1:
	move $t8, $ra
	
	li $v0, 8
	bne, $s1, $v0, correctFrogLog1Return

	# Rerender previous location
	move $a1, $s1
	addi $a0, $s0, -1
	jal loadCache
	
	move $a1, $s1
	move $a0, $s0
	
	# Check if frog is dead
	jal checkDeathRiver

	# Cache new location
	jal storeCache
	
	move $a1, $s1
	move $a0, $s0
	li $a2, 0x15b139
	jal setFrog
	
	correctFrogLog1Return:
		move $ra, $t8
		jr $ra

correctFrogLog2:
	move $t8, $ra
	
	li $v0, 4
	bne, $s1, $v0, correctFrogLog2Return

	# Rerender previous location
	move $a1, $s1
	addi $a0, $s0, -1
	jal loadCache
	
	move $a1, $s1
	move $a0, $s0
	
	# Check if frog is dead
	jal checkDeathRiver

	# Cache new location
	jal storeCache
	
	move $a1, $s1
	move $a0, $s0
	li $a2, 0x15b139
	jal setFrog
	
	correctFrogLog2Return:
		move $ra, $t8
		jr $ra

respondW:
	li $a0, 75
	li $a1, 150
	li $a2, 104
	li $a3, 127
	li $v0, 31
	syscall
	
	move $t8, $ra
	
	# Rerender previous location
	move $a1, $s1
	move $a0, $s0
	jal loadCache
	
	addi $s1, $s1, -4
	move $a1, $s1
	move $a0, $s0
	
	# Cache new location
	jal storeCache
	
	# Check if frog is dead
	jal checkDeathRoad
	jal checkDeathRiver
	jal checkDeathFinal
	jal checkWin
	
	li $a2, 0x15b139
	jal setFrog
	
	respondWReturn:
		move $ra, $t8
		jr $ra
		
respondA:
	li $a0, 75
	li $a1, 150
	li $a2, 104
	li $a3, 127
	li $v0, 31
	syscall
	
	move $t8, $ra
	
	li $a0, 0 # Check boundary
	beq $s0, $a0, respondAReturn
	
	# Rerender previous location
	move $a1, $s1
	move $a0, $s0
	jal loadCache
	
	addi $s0, $s0, -2
	move $a1, $s1
	move $a0, $s0
	
	# Cache new location
	jal storeCache
	
	# Check if frog is dead
	jal checkDeathRoad
	jal checkDeathRiver
	jal checkDeathFinal
	
	li $a2, 0x15b139
	jal setFrogWest
	
	respondAReturn:
		move $ra, $t8
		jr $ra

respondD:
	li $a0, 75
	li $a1, 150
	li $a2, 104
	li $a3, 127
	li $v0, 31
	syscall
	
	move $t8, $ra
	
	li $a0, 28 # Check boundary
	beq $s0, $a0, respondDReturn
	
	# Rerender previous location
	move $a1, $s1
	move $a0, $s0
	jal loadCache
	
	addi $s0, $s0, 2
	move $a1, $s1
	move $a0, $s0
	
	# Cache new location
	jal storeCache
	
	# Check if frog is dead
	jal checkDeathRoad
	jal checkDeathRiver
	jal checkDeathFinal
	
	li $a2, 0x15b139
	jal setFrogEast
	
	respondDReturn:
		move $ra, $t8
		jr $ra

respondS:
	li $a0, 75
	li $a1, 150
	li $a2, 104
	li $a3, 127
	li $v0, 31
	syscall

	move $t8, $ra
	li $a1, 24 # Check boundary
	beq $s1, $a1, respondSReturn
	
	# Rerender previous location
	move $a1, $s1
	move $a0, $s0
	jal loadCache
	
	addi $s1, $s1, 4
	move $a1, $s1
	move $a0, $s0
	
	# Cache new location
	jal storeCache
	
	# Check if frog is dead
	jal checkDeathRoad
	jal checkDeathRiver
	jal checkDeathFinal
	
	li $a2, 0x15b139
	jal setFrogSouth
	
	
	respondSReturn:
		move $ra, $t8
		jr $ra


storeCache:  # Store the 4x4 grid starting at ($a0, $a1) in memory starting from 0x10000000
	# Parse frog coordinate
	li $v0, 4
	li $v1, 128
	mult $v0, $a0
	mflo $v0
	mult $v1, $a1
	mflo $v1
	add $v0, $v0, $v1
	add $v0, $v0, $t0
	
	li $t1, 0x10000000
	
	lw $v1, 0($v0)
	sw $v1, 0($t1)
	lw $v1, 4($v0)
	sw $v1, 4($t1)
	lw $v1, 8($v0)
	sw $v1, 8($t1)
	lw $v1, 12($v0)
	sw $v1, 12($t1)
	
	lw $v1, 128($v0)
	sw $v1, 16($t1)
	lw $v1, 132($v0)
	sw $v1, 20($t1)
	lw $v1, 136($v0)
	sw $v1, 24($t1)
	lw $v1, 140($v0)
	sw $v1, 28($t1)
	
	lw $v1, 256($v0)
	sw $v1, 32($t1)
	lw $v1, 260($v0)
	sw $v1, 36($t1)
	lw $v1, 264($v0)
	sw $v1, 40($t1)
	lw $v1, 268($v0)
	sw $v1, 44($t1)
	
	lw $v1, 384($v0)
	sw $v1, 48($t1)
	lw $v1, 388($v0)
	sw $v1, 52($t1)
	lw $v1, 392($v0)
	sw $v1, 56($t1)
	lw $v1, 396($v0)
	sw $v1, 60($t1)
	
	jr $ra

loadCache:  # load the 4x4 grid starting at ($a0, $a1) in memory starting from 0x10000000
	move $t9, $ra
	
	li $t3, 0x10000000
	move $t1, $a0
	move $t2, $a1
	
	addi $a0, $a0, 0
	addi $a1, $a1, 0
	lw $a2, 0($t3)
	jal setPixelColor
	move $a0, $t1
	move $a1, $t2
	
	addi $a0, $a0, 1
	addi $a1, $a1, 0
	lw $a2, 4($t3)
	jal setPixelColor
	move $a0, $t1
	move $a1, $t2
	
	addi $a0, $a0, 2
	addi $a1, $a1, 0
	lw $a2, 8($t3)
	jal setPixelColor
	move $a0, $t1
	move $a1, $t2
	
	addi $a0, $a0, 3
	addi $a1, $a1, 0
	lw $a2, 12($t3)
	jal setPixelColor
	move $a0, $t1
	move $a1, $t2
	
	addi $a0, $a0, 0
	addi $a1, $a1, 1
	lw $a2, 16($t3)
	jal setPixelColor
	move $a0, $t1
	move $a1, $t2
	
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	lw $a2, 20($t3)
	jal setPixelColor
	move $a0, $t1
	move $a1, $t2
	
	addi $a0, $a0, 2
	addi $a1, $a1, 1
	lw $a2, 24($t3)
	jal setPixelColor
	move $a0, $t1
	move $a1, $t2
	
	addi $a0, $a0, 3
	addi $a1, $a1, 1
	lw $a2, 28($t3)
	jal setPixelColor
	move $a0, $t1
	move $a1, $t2
	
	addi $a0, $a0, 0
	addi $a1, $a1, 2
	lw $a2, 32($t3)
	jal setPixelColor
	move $a0, $t1
	move $a1, $t2
	
	addi $a0, $a0, 1
	addi $a1, $a1, 2
	lw $a2, 36($t3)
	jal setPixelColor
	move $a0, $t1
	move $a1, $t2
	
	addi $a0, $a0, 2
	addi $a1, $a1, 2
	lw $a2, 40($t3)
	jal setPixelColor
	move $a0, $t1
	move $a1, $t2
	
	addi $a0, $a0, 3
	addi $a1, $a1, 2
	lw $a2, 44($t3)
	jal setPixelColor
	move $a0, $t1
	move $a1, $t2
	
	addi $a0, $a0, 0
	addi $a1, $a1, 3
	lw $a2, 48($t3)
	jal setPixelColor
	move $a0, $t1
	move $a1, $t2
	
	addi $a0, $a0, 1
	addi $a1, $a1, 3
	lw $a2, 52($t3)
	jal setPixelColor
	move $a0, $t1
	move $a1, $t2
	
	addi $a0, $a0, 2
	addi $a1, $a1, 3
	lw $a2, 56($t3)
	jal setPixelColor
	move $a0, $t1
	move $a1, $t2
	
	addi $a0, $a0, 3
	addi $a1, $a1, 3
	lw $a2, 60($t3)
	jal setPixelColor
	move $a0, $t1
	move $a1, $t2
	
	move $ra, $t9
	jr $ra
	

setPixelColor: # We assume that $a0 stores the x value, $a1 stores the y value, and $a2 stores the color
	li $v0, 128 # Parse y pixel coordinate to valid display address
	mult $v0 $a1
	mflo $a1
	
	li $v0, 4  # Parse x pixel coordinate to valid display address
	mult $v0 $a0
	mflo $v0
	
	add $v0, $v0, $a1 # Final pixel location for sw operation
	add $v0, $t0, $v0
	
	sw $a2, 0($v0)
	jr $ra


setHBar: # Draw a horizontal bar across the screen of height 4, with topmost y-coordinate stored at $a1 color stored at $a2
	li $a0, 31
	move $t9, $ra
	HBarLoop1:
		addi $a0, $a0, 1
		blez $a0, SetHBarReturn
		addi $a0, $a0, -1
		move $v1, $a1

		jal setPixelColor
		move $a1, $v1
		addi $a1, $a1, 1
		jal setPixelColor
		move $a1, $v1
		addi $a1, $a1, 2
		jal setPixelColor
		move $a1, $v1
		addi $a1, $a1, 3
		jal setPixelColor
		move $a1, $v1
		
		addi $a0, $a0, -1 #decrement counter
		j HBarLoop1 #jumps back to the top of loop 
	SetHBarReturn:
		move $ra, $t9
		jr $ra
		
setBkgd: # Paints the background of the game
	move $t8, $ra
	
	li $a2, 0x000000 # Life Spot
	li $a1, 28
	jal setHBar
	
	li $a2, 0x520c2e # Start
	li $a1, 24
	jal setHBar
	li $a1, 12 # Safe spot
	jal setHBar
	
	li $a2, 0x433f3c # Road
	li $a1, 16
	jal setHBar
	li $a2, 0x433f3c
	li $a1, 20
	jal setHBar
	
	li $a2, 0x000078 # Rivcr
	li $a1, 8
	jal setHBar
	li $a2, 0x000078 
	li $a1, 4
	jal setHBar
	
	move $ra, $t8
	jr $ra
	
setFrog: # Given position of the frog's top left pixel stored in $a0 (x) $a1 (y) and color at $a2
	move $t9, $ra
	
	move $t1, $a0
	move $t2, $a1
	
	jal setPixelColor
	addi $a0, $t1, 3
	move $a1, $t2
	jal setPixelColor
	
	move $a0, $t1
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 1
	jal setPixelColor
	
	addi $a0, $t1, 1
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 2
	jal setPixelColor
	
	move $a0, $t1
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 3
	jal setPixelColor
	
	li $a2, 0xfd2000
	addi $a0, $t1, 1
	move $a1, $t2
	jal setPixelColor
	li $a2, 0x20fdf0
	addi $a0, $t1, 2
	move $a1, $t2
	jal setPixelColor
	
	move $ra, $t9
	jr $ra
	
	
setFrogEast: # Draw the frog facing east
	move $t9, $ra
	
	move $t1, $a0
	move $t2, $a1
	
	jal setPixelColor
	addi $a0, $t1, 2
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 3
	move $a1, $t2
	jal setPixelColor
	
	move $a0, $t1
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 1
	jal setPixelColor

	move $a0, $t1
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 2
	jal setPixelColor	

	
	move $a0, $t1
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 3
	jal setPixelColor
	
	li $a2, 0xfd2000
	addi $a0, $t1, 3
	addi $a1, $t2, 1
	jal setPixelColor
	li $a2, 0x20fdf0
	addi $a0, $t1, 3
	addi $a1, $t2, 2
	jal setPixelColor
	
	move $ra, $t9
	jr $ra


setFrogWest: # Draw the frog facing east
	move $t9, $ra
	
	move $t1, $a0
	move $t2, $a1
	
	jal setPixelColor
	addi $a0, $t1, 1
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 3
	move $a1, $t2
	jal setPixelColor
	
	addi $a0, $t1, 1
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 1
	jal setPixelColor

	addi $a0, $t1, 1
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 2
	jal setPixelColor	

	move $a0, $t1
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 3
	jal setPixelColor
	
	li $a2, 0xfd2000
	addi $a0, $t1, 0
	addi $a1, $t2, 2
	jal setPixelColor
	li $a2, 0x20fdf0
	addi $a0, $t1, 0
	addi $a1, $t2, 1
	jal setPixelColor
	
	move $ra, $t9
	jr $ra
	
	
setFrogSouth: # Given position of the frog's top left pixel stored in $a0 (x) $a1 (y) and color at $a2
	move $t9, $ra
	
	move $t1, $a0
	move $t2, $a1
	
	
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 3
	jal setPixelColor
	
	move $a0, $t1
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 2
	jal setPixelColor
	
	addi $a0, $t1, 1
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 1
	jal setPixelColor
	
	move $a0, $t1
	addi $a1, $t2, 0
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 0
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 0
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 0
	jal setPixelColor
	
	li $a2, 0xfd2000
	addi $a0, $t1, 2
	addi $a1, $t2, 3
	jal setPixelColor
	li $a2, 0x20fdf0
	addi $a0, $t1, 1
	addi $a1, $t2, 3
	jal setPixelColor
	
	move $ra, $t9
	jr $ra

setSquare: # Draw the frog facing east
	move $t9, $ra
	
	move $t1, $a0
	move $t2, $a1
	
	move $a0, $t1
	addi $a1, $t2, 0
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 0
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 0
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 0
	jal setPixelColor
	
	move $a0, $t1
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 1
	jal setPixelColor
	
	move $a0, $t1
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 2
	jal setPixelColor
	
	move $a0, $t1
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 3
	jal setPixelColor
	
	move $ra, $t9
	jr $ra	


setLife: # Set the number of lives displayed, stored at $s2
	move $t8, $ra
	
	li $a0, 0
	li $a1, 28
	
	li $v1, 5
	
	mult $s2, $v1
	mflo $s2
	
	li $a3, 0
	
	setLifeLoop1:
		li $a2, 0x266b00
		beq $s2, $a3, setLifeReturn
		move $a0, $a3
		li $a1, 28
		jal setFrog
		addi $a3, $a3, 5
		j setLifeLoop1

	setLifeReturn:
		div $s2, $v1
		mflo $s2
		move $ra, $t8
		jr $ra

setCar1: # Given position of the car's top left pixel stored in $a0 (x) $a1 (y) and color at $a2
	move $t9, $ra
	
	move $t1, $a0
	move $t2, $a1
	
	li $a2, 0xdbb515
	jal setPixelColor
	addi $a0, $t1, 1
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 2
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 3
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 4
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 5
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 6
	move $a1, $t2
	jal setPixelColor
	
	addi $a0, $t1, 0
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 1
	li $a2, 0x064e51
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 1
	li $a2, 0xdbb515
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 4
	addi $a1, $t2, 1
	li $a2, 0x064e51
	jal setPixelColor
	addi $a0, $t1, 5
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 6
	addi $a1, $t2, 1
	li $a2, 0xdbb515
	jal setPixelColor
	
	addi $a0, $t1, 0
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 2
	li $a2, 0x064e51
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 2
	li $a2, 0xdbb515
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 4
	addi $a1, $t2, 2
	li $a2, 0x064e51
	jal setPixelColor
	addi $a0, $t1, 5
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 6
	addi $a1, $t2, 2
	li $a2, 0xdbb515
	jal setPixelColor
	
	addi $a0, $t1, 0
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 4
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 5
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 6
	addi $a1, $t2, 3
	jal setPixelColor
	
	move $ra, $t9
	jr $ra

setCar2: # Given position of the car's top left pixel stored in $a0 (x) $a1 (y) and color at $a2
	move $t9, $ra
	
	move $t1, $a0
	move $t2, $a1
	
	li $a2, 0x2999ff
	jal setPixelColor
	addi $a0, $t1, 1
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 2
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 3
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 4
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 5
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 6
	move $a1, $t2
	jal setPixelColor
	
	addi $a0, $t1, 0
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 1
	li $a2, 0x064e51
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 1
	li $a2, 0x2999ff
	jal setPixelColor
	addi $a0, $t1, 4
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 5
	addi $a1, $t2, 1
	li $a2, 0x064e51
	jal setPixelColor
	addi $a0, $t1, 6
	addi $a1, $t2, 1
	li $a2, 0x2999ff
	jal setPixelColor
	
	addi $a0, $t1, 0
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 2
	li $a2, 0x064e51
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 2
	li $a2, 0x2999ff
	jal setPixelColor
	addi $a0, $t1, 4
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 5
	addi $a1, $t2, 2
	li $a2, 0x064e51
	jal setPixelColor
	addi $a0, $t1, 6
	addi $a1, $t2, 2
	li $a2, 0x2999ff
	jal setPixelColor
	
	addi $a0, $t1, 0
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 4
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 5
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 6
	addi $a1, $t2, 3
	jal setPixelColor
	
	move $ra, $t9
	jr $ra


setLog1: # Given position of the car's top left pixel stored in $a0 (x) $a1 (y) and color at $a2
	move $t9, $ra
	
	move $t1, $a0
	move $t2, $a1
	
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 1
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 2
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 3
	move $a1, $t2
	li $a2, 0xa93f0a
	jal setPixelColor
	addi $a0, $t1, 4
	move $a1, $t2
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 5
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 6
	move $a1, $t2
	li $a2, 0xa93f0a
	jal setPixelColor
	addi $a0, $t1, 7
	move $a1, $t2
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 8
	move $a1, $t2
	li $a2, 0xa93f0a
	jal setPixelColor
	addi $a0, $t1, 9
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 10
	move $a1, $t2
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 11
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 12
	move $a1, $t2
	li $a2, 0x906932
	jal setPixelColor
	
	addi $a0, $t1, 0
	addi $a1, $t2, 1
	li $a2, 0xa93f0a
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 1
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 4
	addi $a1, $t2, 1
	li $a2, 0xa93f0a
	jal setPixelColor
	addi $a0, $t1, 5
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 6
	addi $a1, $t2, 1
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 7
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 8
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 9
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 10
	addi $a1, $t2, 1
	li $a2, 0xa93f0a
	jal setPixelColor
	addi $a0, $t1, 11
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 12
	addi $a1, $t2, 1
	li $a2, 0x906932
	jal setPixelColor
	
	addi $a0, $t1, 0
	addi $a1, $t2, 2
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 2
	li $a2, 0xa93f0a
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 4
	addi $a1, $t2, 2
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 5
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 6
	addi $a1, $t2, 2
	li $a2, 0xa93f0a
	jal setPixelColor
	addi $a0, $t1, 7
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 7
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 8
	addi $a1, $t2, 2
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 9
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 10
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 11
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 12
	addi $a1, $t2, 2
	li $a2, 0x906932
	jal setPixelColor
	
	li $a2, 0x402e16
	addi $a0, $t1, 0
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 4
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 5
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 6
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 7
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 8
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 9
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 10
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 11
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 12
	addi $a1, $t2, 3
	li $a2, 0x805d2c
	jal setPixelColor
	
	move $ra, $t9
	jr $ra
	
setLog2: # Given position of the car's top left pixel stored in $a0 (x) $a1 (y) and color at $a2
	move $t9, $ra
	
	move $t1, $a0
	move $t2, $a1
	
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 1
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 2
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 3
	move $a1, $t2
	li $a2, 0xa93f0a
	jal setPixelColor
	addi $a0, $t1, 4
	move $a1, $t2
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 5
	move $a1, $t2
	jal setPixelColor
	addi $a0, $t1, 6
	move $a1, $t2
	li $a2, 0xa93f0a
	jal setPixelColor
	addi $a0, $t1, 7
	move $a1, $t2
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 8
	move $a1, $t2
	li $a2, 0xa93f0a
	jal setPixelColor
	addi $a0, $t1, 9
	move $a1, $t2
	li $a2, 0x906932
	jal setPixelColor
	
	addi $a0, $t1, 0
	addi $a1, $t2, 1
	li $a2, 0xa93f0a
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 1
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 4
	addi $a1, $t2, 1
	li $a2, 0xa93f0a
	jal setPixelColor
	addi $a0, $t1, 5
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 6
	addi $a1, $t2, 1
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 7
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 8
	addi $a1, $t2, 1
	jal setPixelColor
	addi $a0, $t1, 9
	addi $a1, $t2, 1
	li $a2, 0x906932
	jal setPixelColor
	
	addi $a0, $t1, 0
	addi $a1, $t2, 2
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 2
	li $a2, 0xa93f0a
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 4
	addi $a1, $t2, 2
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 5
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 6
	addi $a1, $t2, 2
	li $a2, 0xa93f0a
	jal setPixelColor
	addi $a0, $t1, 7
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 7
	addi $a1, $t2, 2
	jal setPixelColor
	addi $a0, $t1, 8
	addi $a1, $t2, 2
	li $a2, 0x5c2c14
	jal setPixelColor
	addi $a0, $t1, 9
	addi $a1, $t2, 2
	li $a2, 0x906932
	jal setPixelColor
	
	li $a2, 0x402e16
	addi $a0, $t1, 0
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 1
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 2
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 3
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 4
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 5
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 6
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 7
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 8
	addi $a1, $t2, 3
	jal setPixelColor
	addi $a0, $t1, 9
	addi $a1, $t2, 3
	li $a2, 0x805d2c
	jal setPixelColor
	
	move $ra, $t9
	jr $ra


moveCar1:
	li $a0, 512
	li $a1, 0
	
	MoveCar1Loop2:
		beq $a0, $a1, MoveCar1Return
		
		li $v0, 0
		li $v1, 0
		
		addi $v0, $a1, 2556
		add $t8, $v0, $t0
		
		addi $v1, $a1, 2684
		add $t9, $v1, $t0
		
		addi $a1, $a1 128
		
		lw $t2, ($t8)
		lw $t3, ($t9)
		sw $t2, ($t9)
	
		MoveCar1Loop1:
			beq $v0, $v1, MoveCar1Loop2
			add $t1, $t0, $v0
			move $t2, $t3
			lw $t3, 4($t1)
			sw $t2, 4($t1)
			addi $v0, $v0, 4
			j MoveCar1Loop1
	
		MoveCar1Return:
			jr $ra

moveCar2:
	li $a0, 512
	li $a1, 0
	
	MoveCar2Loop2:
		beq $a0, $a1, MoveCar2Return
		
		li $v0, 0
		li $v1, 0
		
		addi $v0, $a1, 2176
		add $t8, $v0, $t0
		
		addi $v1, $a1, 2048
		add $t9, $v1, $t0
		
		addi $a1, $a1 128
		
		lw $t2, ($t8)
		lw $t3, ($t9)
		sw $t2, ($t9)
	
		MoveCar2Loop1:
			beq $v0, $v1, MoveCar2Loop2
			add $t1, $t0, $v0
			move $t2, $t3
			lw $t3, -4($t1)
			sw $t2, -4($t1)
			addi $v0, $v0, -4
			j MoveCar2Loop1
	
		MoveCar2Return:
			jr $ra

moveLog1:
	li $a0, 512
	li $a1, 0
	
	MoveLog1Loop2:
		beq $a0, $a1, MoveLog1Return
		
		li $v0, 0
		li $v1, 0
		
		addi $v0, $a1, 1152
		add $t8, $v0, $t0
		
		addi $v1, $a1, 1024
		add $t9, $v1, $t0
		
		addi $a1, $a1 128
		
		lw $t2, ($t8)
		lw $t3, ($t9)
		sw $t2, ($t9)
	
		MoveLog1Loop1:
			beq $v0, $v1, MoveLog1Loop2
			add $t1, $t0, $v0
			move $t2, $t3
			lw $t3, -4($t1)
			sw $t2, -4($t1)
			addi $v0, $v0, -4
			j MoveLog1Loop1
	
		MoveLog1Return:
			jr $ra
			
moveLog2:
	li $a0, 512
	li $a1, 0
	
	MoveLog2Loop2:
		beq $a0, $a1, MoveLog2Return
		
		li $v0, 0
		li $v1, 0
		
		addi $v0, $a1, 640
		add $t8, $v0, $t0
		
		addi $v1, $a1, 512
		add $t9, $v1, $t0
		
		addi $a1, $a1 128
		
		lw $t2, ($t8)
		lw $t3, ($t9)
		sw $t2, ($t9)
	
		MoveLog2Loop1:
			beq $v0, $v1, MoveLog2Loop2
			add $t1, $t0, $v0
			move $t2, $t3
			lw $t3, -4($t1)
			sw $t2, -4($t1)
			addi $v0, $v0, -4
			j MoveLog2Loop1
	
		MoveLog2Return:
			jr $ra

killFrog:
	# Kill the frog and show death animation
	
	
	li $a2, 0xff0000
	jal setFrog
	
	deathMusic:
	li $a0, 45
	li $a1, 900
	li $a2, 104
	li $a3, 127
	li $v0, 31
	syscall
	
	li $a0, 900
	li $v0, 32
	syscall
	
	lw $v0, 0xffff0000
	beqz $v0, NoKeyDeath
	lw $v0, 0xffff0004
	li $v1, 0x71
	beq $v0, $v1, Exit
	li $v1, 0x72
	beq $v0, $v1, main
	
	NoKeyDeath:
	beqz $s2 checkPartialWin
	
	move $a0, $s0
	move $a1, $s1
	jal loadCache
	
	addi $s2, $s2, -1
	
	j newGame
	
	checkPartialWin:
	bne $zero, $s3, winMusic
	j deathMusic

checkDeathRoad:
	# Check if the frog had been killed on the road
	li $v0, 16 
	beq $v0, $s1, RoadDeathCondition
	
	li $v0, 20
	beq $v0, $s1, RoadDeathCondition
	
	j CheckDeathRoadReturn
	
	RoadDeathCondition:
		li $v0, 4
		li $v1, 128
		mult $v0, $a0
		mflo $v0
		mult $v1, $a1
		mflo $v1
		add $v0, $v0, $v1
		add $v0, $v0, $t0
	
		li $t5, 0x433f3c
		lw $v1, 0($v0)
		bne $v1, $t5, killFrog
	
		addi $v0, $v0, 12
		lw $v1, 0($v0)
		bne $v1, $t5, killFrog
	
	CheckDeathRoadReturn:
		jr $ra

checkDeathRiver:
	# Check if the frog had been killed on the road
	li $v0, 8
	beq $v0, $s1, RiverDeathCondition
	
	li $v0, 4
	beq $v0, $s1, RiverDeathCondition
	
	j CheckDeathRiverReturn
	
	RiverDeathCondition:
		li $v0, 4
		li $v1, 128
		mult $v0, $a0
		mflo $v0
		mult $v1, $a1
		mflo $v1
		add $v0, $v0, $v1
		add $v0, $v0, $t0
	
		li $t5, 0x000078
		lw $v1, 0($v0)
		beq $v1, $t5, killFrog
	
		addi $v0, $v0, 12
		lw $v1, 0($v0)
		beq $v1, $t5, killFrog
	
	CheckDeathRiverReturn:
		jr $ra

checkDeathFinal:
	# Check if the frog had been killed on the road
	li $v0, 0 
	beq $v0, $s1, FinalDeathCondition
	
	j CheckDeathFinalReturn
	
	FinalDeathCondition:
		li $v0, 4
		li $v1, 128
		mult $v0, $a0
		mflo $v0
		mult $v1, $a1
		mflo $v1
		add $v0, $v0, $v1
		add $v0, $v0, $t0
	
		li $t5, 0x00d9ab
		lw $v1, 0($v0)
		bne $v1, $t5, killFrog
	
		addi $v0, $v0, 12
		lw $v1, 0($v0)
		bne $v1, $t5, killFrog
	
	CheckDeathFinalReturn:
		jr $ra

win:
	move $a0, $s0
	move $a1, $s1
	jal storeCache
	
	li $a2, 0x15b139
	jal setFrog
	
	winMusic:
	
	li $a0, 69
	li $a1, 300
	li $a2, 104
	li $a3, 127
	li $v0, 31
	syscall
	li $a0, 300
	li $v0, 32
	syscall
	
	li $a0, 71
	li $a1, 300
	li $a2, 104
	li $a3, 127
	li $v0, 31
	syscall
	li $a0, 300
	li $v0, 32
	syscall
	
	li $a0, 73
	li $a1, 300
	li $a2, 104
	li $a3, 127
	li $v0, 31
	syscall
	li $a0, 300
	li $v0, 32
	syscall
	
	lw $v0, 0xffff0000
	beqz $v0, NoKeyWin
	lw $v0, 0xffff0004
	li $v1, 0x71
	beq $v0, $v1, Exit
	li $v1, 0x72
	beq $v0, $v1, main
	NoKeyWin:
	beqz $s2, winMusic
	
	addi $s2, $s2, -1
	addi $s3, $s3, 1
	
	j newGame

checkWin:
	beqz $s1, win
	jr $ra

blackOut:
	move $t8, $ra

	li $a2, 0x000000 # Life Spot
	li $a1, 28
	jal setHBar
	li $a1, 24
	jal setHBar
	li $a1, 20
	jal setHBar
	li $a1, 16
	jal setHBar
	li $a1, 12
	jal setHBar
	li $a1, 8
	jal setHBar
	li $a1, 4
	jal setHBar
	li $a1, 0
	jal setHBar
	
	li $a0, 69 # Ending buzz
	li $a1, 1000
	li $a2, 104
	li $a3, 127
	li $v0, 31
	syscall
	li $a0, 1000
	li $v0, 32
	syscall
	
	move $ra, $t8
	jr $ra
	
pause:
	li $a0, 71 # Pause buzz
	li $a1, 100
	li $a2, 104
	li $a3, 127
	li $v0, 31
	syscall
	pause1:
	lw $v0, 0xffff0000
	beqz $v0, NoKeyPause
	lw $v0, 0xffff0004
	li $v1, 0x70
	beq $v0, $v1, resume1
	NoKeyPause:
	j pause1
	resume1:
	li $a0, 71 # Resume buzz
	li $a1, 100
	li $a2, 104
	li $a3, 127
	li $v0, 31
	syscall
	j resume

Exit:
jal blackOut
li $v0, 10 # terminate the program gracefully
syscall
