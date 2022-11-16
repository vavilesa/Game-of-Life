    .arch armv7
    .cpu cortex-a53
    .equ 	NUL, 0

    .global asm_doRow
    // !!! SET FP_OFFSET TO THE NUMBER OF (SAVED REGISTERS -1 * 4)
	
	// ADJUST FOR CALLEE SAVED REGISTERS
	.equ 	FP_OFFSET, 32 	     // (# of saved regs - 1) * 4
	.equ    NCOLS_OFFSET, 4      // number columns	(5th parameter)
	
	// ALLOCATE LOCAL SPACE, PARAMETER SPACE
	// (you can save incoming parameters in either one)
	.equ	LOCAL_SPACE, 16	     // total local space
	.equ    PARAM_SPACE, 0       // total param space
	
	// local variable offsets
	// offsets are referenced to the framepointer.
	.equ    DEST_OFFSET, -36
	.equ    SRC_OFFSET, -40
	.equ    ROW_OFFSET, -44
	.equ    NROW_OFFSET, -48
	

asm_doRow:	
	push {r4-r10, fp, lr}
	add fp, sp, #FP_OFFSET
	sub sp, sp, #(LOCAL_SPACE + PARAM_SPACE)
	
	// store arguments
	str r0, [fp, #DEST_OFFSET]			// r0 = dest
	str r1, [fp, #SRC_OFFSET]			// r1 = src
	str r2, [fp, #ROW_OFFSET]			// r2 = row
	str r3, [fp, #NROW_OFFSET]			// r3 = nRows
	
	ldr r0, [fp, #NROW_OFFSET]			// r0 = nRows
	ldr r1, [fp, #NCOLS_OFFSET]			// r1 = nCols
	bl setNRowsNCols				

	ldr r10, [fp, #NCOLS_OFFSET]			// r10 = nCols
	mov r9, #0					// i = 0
	
columns:						// iterates through each column in the given row
	cmp r9, r10					// while (i < nCols) {
	bge doneCol					// .
							// .
	mov r6, #0					//		r6 = 0; num of alive neighbors
	mov r5, #0					//		j = 0;
							// .
neighbor:						//	searches through the 8 adjacent neighbors
	cmp r5, #8					//			while (j < 8) {
	bge done					//			.
							//			.
	ldr r8, [fp, #ROW_OFFSET]			//			r8, currRow = row;
	mov r7, r9					//			r7, currCol = i;
							//
							//				switch (r5/j) {
	cmp	r5, #0					//				case 0: right
	bne 1f						//				
	add r7, r7, #1					//					currCol += 1;
	b 2f						//					break;
1:							//		
	cmp	r5, #1					//				case 1: left
	bne 1f						//				
	sub r7, r7, #1					//					currCol -= 1;
	b 2f						//					break;
1:							//				
	cmp	r5, #2					//				case 2: up
	bne 1f						//				
	sub r8, r8, #1					//					currRow -= 1;
	b 2f						//					break;
1:							//				
	cmp	r5, #3					//				case 3: up right
	bne 1f						//				
	sub r8, r8, #1					//					currRow -= 1;
	add r7, r7, #1					//					currCol += 1;
	b 2f						//					break;
1:							//				
	cmp	r5, #4					//				case 4: up left
	bne 1f						//				
	sub r8, r8, #1					//					currRow -= 1;
	sub r7, r7, #1					//					currCol -= 1;
	b 2f						//					break;
1:							//				
	cmp	r5, #5					//				case 5: down
	bne 1f						//				
	add r8, r8, #1					//					currRow += 1;
	b 2f						//					break;
1:							//				
	cmp	r5, #6					//				case 6: down right
	bne 1f						//				
	add r8, r8, #1					//					currRow += 1;
	add r7, r7, #1					//					currCol += 1;
	b 2f						//					break;
1:							//				
	cmp	r5, #7					//				case 7: down left
	bne 2f						//				
	add r8, r8, #1					//					currRow += 1;
	sub r7, r7, #1					//					currCol -= 1;		
2:							//				}
							// .
	mov r0, r8					//			r0 = currRow;
	mov r1, r7					//			r1 = currCol
							// .		
	bl nGetIndexRC					//			r0 = index;
							// .		
	ldr r1, [fp, #SRC_OFFSET]			//			r1 = src
	add r0, r0, r1					//			r0 = index + src
							// .		
	ldrb r2, [r0]					//			r2 = *(index +src)
							// .			
	cmp r2, #1					//			if (r2 == 1) {
	bne 1f						//			.
	add r6, #1					//				neighbors++;
1:							//			}
							// .		
	add r5, r5, #1					//			j++;	
	b neighbor					// .
done:							//		}
							// .
	ldr r0, [fp, #ROW_OFFSET]			//		r0 = row
	mov r1, r9					//		r1 = col
	bl nGetIndexRC					//		r0 = currIndex;
							// .
	mov r3, #0					//		r3 = 0;
	mov r4, #1					//		r4 = 1;
							// .
	ldr r1, [fp, #DEST_OFFSET]			//		r1 = dest
	add r1, r0, r1					//		r1 = dest + currIndex
							// .
	cmp r6, #1					//		if (neighbors <= 1 || neighbors >= 4) {
	ble 1f						//		. dead cell, 1 = loneliness, 4 = overpopulation
	cmp r6, #4					//		.
	blt 2f						//		.
1:							// .	
	strb r3, [r1]					//			*(dest + index) = 0;
	b 3f						//		.
2:							//		}	
							//		cell with three neighbors revives or stays alive
	cmp r6, #3					//		else if (neighbors == 3) {
	bne 1f						//		.
	strb r4, [r1]					//			*(dest + index) = 1;	
	b 3f						//		}
1:							//		alive cell with 2 neighbors stays alive		
	ldr r2, [fp, #SRC_OFFSET]			//		r2 = src;
	add r2, r2, r0					//		r2 = src + currIndex;
	ldrb r2, [r2]					//		r2 = *(src + currIndex)
	cmp r2, #1					//		else if (*(src + index) == 1) {
	bne 1f						//
	strb r4, [r1]					//			*(dest + index) = 1;	
	b 3f						//		}
1:							//		else {	//dead cell stays dead
	strb r3, [r1]					//			*(dest + index) = 0;	
3:							//		}
							// .
	add r9, r9, #1					// i++;
	b columns					// . 
							// }
doneCol: 
	
	sub sp, fp, #FP_OFFSET
	pop {r4-r10, fp, lr}
	bx lr