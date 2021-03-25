/*
 * postfix calculator (assembly language version)
 * function implementation
 */

.equ TOK_INT, 0
.equ TOK_OP, 1
.equ TOK_UNKNOWN, 2
.equ MAX_STACK, 20

	.section .rodata

eNegativeValue: .string "Negative value"
errorFmt: .string "Error: %s\n"
errorStackFull: .string "Stack full"
errorStackEmpty: .string "Stack empty"

	.section .text

/*
 * addPositive function (this is just an example function)
 */
	.globl addPositive
addPositive:
	subq $8, %rsp                /* align stack pointer */

	movq $0, %r10                /* let %r10 be 0 */
	cmpq %rdi, %r10              /* compare 1st param to 0 */
	jg .LaddPositiveNegativeOperand /* if less, it's negative */
	cmpq %rsi, %r10              /* compare 2nd param to 0 */
	jg .LaddPositiveNegativeOperand /* if less, it's negative */

	/* both operands are non-negative, do the addition */
	movq %rsi, %rax              /* move second parameter to %rax */
	addq %rdi, %rax              /* add first parameter to second */
	jmp .LaddPositiveDone

.LaddPositiveNegativeOperand:
	movq $eNegativeValue, %rdi
	call fatalError
9:	jmp 9b                       /* should not get here */

.LaddPositiveDone:
	/* the sum is now in %rax */
	addq $8, %rsp                /* restore stack pointer */
	ret

/*
 * fatalError - print an error message an exit with an exit code of 1.
 * Prints a message of the form "Error: <message text>" to standard output.
 * Does not return!
 *
 * Params:
 *   msg - description of the error which occurred
 */
	.globl fatalError
fatalError:
    subq $8, %rsp /* adjust stack pointer */
	movq %rdi, %rsi /* move error msg into second arg */
	movq $errorFmt, %rdi /* move formatting for msg into first arg */
	call printf /* print error msg in correct format */
	mov $1, %rdi /* move 1 into first arg for exit call with code 1*/
	call exit /* exit program without returning */
    addq $8, %rsp /* restore stack pointer */
    ret /* won't reach here */

/*
 * isSpace - tests a character code to determine whether or not it
 * is a space character.
 *
 * Params:
 *   c - an ASCII character code
 *
 * Returns:
 *   1 if c is a space or tab character, 0 otherwise
 *   (the function is allowed to also return 1 if c is a newline
 *   or carriage return, but it's only required to handle
 *   spaces and tabs)
 */
	.globl isSpace
isSpace:
    subq $8, %rsp /* adjust stack pointer */
    movq $0, %r10 /* initialize return value to 0 */
    cmp $32, %rdi /* check if c is space */
    jz .LisSpaceIncVal /* if so, increment return value and done */
    cmp $9, %rdi /* check if c is tab */
    jz .LisSpaceIncVal /* if so, increment return value and done */
    jmp .LisSpaceDone /* done, return 0 */
.LisSpaceIncVal:
    inc %r10 /* set return value to 1 by incrementing */
    jmp .LisSpaceDone
.LisSpaceDone:
    movq %r10, %rax /* return the return value */
    addq $8, %rsp /* restore stack pointer */
	ret

/*
 * isDigit - tests a character code to determine whether it is one
 * of the digits '0' through '9'
 *
 * Params:
 *   c - an ASCII character code
 *
 * Returns:
 *   1 if c is a digit, 0 otherwise
 */
	.globl isDigit
isDigit:
    subq $8, %rsp /* adjust stack pointer */
    movq $0, %r10 /* initialize return value to 0 */
    cmp $57, %rdi /* check if '9' < c */
    jg .LisDigitDone /* if yes, done return 0*/
    cmp $48, %rdi /* check '0' > c */
    jl .LisDigitDone /* if yes, done return 0*/
    inc %r10 /* set return value to 1 by incrementing */
    jmp .LisDigitDone /* done, return 1 */
.LisDigitDone:
    movq %r10, %rax /* return the return value */
    addq $8, %rsp /* restore stack pointer */
	ret

/*
 * skipws - skips any whitespace characters (as determined by isSpace)
 * at the beginning of a C character string.
 *
 * Params:
 *   s - pointer to a C character string
 *
 * Returns:
 *   pointer to the first non-space character in the string, or NULL
 *   if there are no non-space characters before the end of the string
 *   is reached
 */
	.globl skipws
skipws:
    subq $8, %rsp /* adjust stack pointer */
    pushq %r12 /* push r12 from stack */
    movq %rdi, %r12 /*save copy of s in r10 */
    jmp .LskipwsTop /* begin loop */
.LskipwsTop:
    movzbl (%r12), %edi /* get first char of s */
    cmpb $0, (%r12) /* check if char is null terminator*/
    jz .LskipwsNullDone /* if so, done */
    call isSpace /* call isSpace function */
    cmpl $0, %eax /* check is char is space */
    jz .LskipwsDone /* if not a space, end loop */
    incq %r12 /* move pointer for s forward by one char */
    jmp .LskipwsTop /* loop again */
.LskipwsNullDone:
    movq $0, %rax /* move updated pointer to return value */
    popq %r12 /* pop r12 from stack */
    addq $8, %rsp /* restore stack pointer */
    ret
.LskipwsDone:
    movq %r12, %rax /* move updated pointer to return value */
    popq %r12 /* pop r12 from stack */
    addq $8, %rsp /* restore stack pointer */
    ret

/*
 * tokenType - return the token type (TOK_INT, TOK_OP, or TOK_UNKNOWN)
 * of the token at the beginning of given C character string.
 *
 * Params:
 *   s - nonempty C character string (which should not have any leading
 *       space characters)
 *
 * Returns:
 *   the token type
 */
	.globl tokenType
tokenType:
    subq $8, %rsp /* adjust stack pointer */
    movq %rdi, %r10 /* move s to r10 */
    movzbq (%r10), %rdi /* get first char from s */
    call isDigit /* check if first c has digit, return 1 in rax if so */
    cmp $1, %rax /* check is digit */
    jz .LtokenTypeDigit /* if so, return token int */
    
    /* check if op */
    cmp $43, %rdi /* addition */
    jz .LtokenTypeOP /* if so, return token op */
    cmp $45, %rdi /* subtraction */
    jz .LtokenTypeOP /* if so, return token op */
    cmp $42, %rdi /* multiplication */
    jz .LtokenTypeOP /* if so, return token op */
    cmp $47, %rdi /* division */
    jz .LtokenTypeOP /* if so, return token op */
    
    movq $TOK_UNKNOWN, %rax /* reach here if not digit nor op */
    jmp .LtokenTypeDone /* if so, return token unkown */
.LtokenTypeDigit:
    movq $TOK_INT, %rax /* return TOK_INT*/
    jmp .LtokenTypeDone
.LtokenTypeOP:
    movq $TOK_OP, %rax /* return TOK_OP*/
    jmp .LtokenTypeDone
.LtokenTypeDone:
    addq $8, %rsp /* restore stack pointer */
	ret

/*
 * consumeInt - consume one or more digit characters at the beginning
 * of given C character string, convert them to an integer value, and
 * store the integer value in the long (64 bit signed integer)
 * variable that pval points to.
 *
 * Params:
 *   s    - pointer to a nonempty C character string which should start
 *          with a digit character
 *   pval - points to a long variable where the converted integer value
 *          should be stored
 *
 * Returns:
 *   pointer to the first character in the string that is not a digit
 */
	.globl consumeInt
consumeInt:
    subq $8, %rsp /* adjust stack pointer */
    pushq %r12 /* push r12 to stack */
    pushq %r14 /* push r14 to stack */
    movq %rdi, %r12 /*save copy of s in r12 */
    movq $0, %r14 /* initialize pval to 0 */
    jmp .LconsumeIntTop /* begin loop */
    
.LconsumeIntTop:
    movzbl (%r12), %eax /* get first char of s TODO: r12d? */
    movq %rax, %rdi /* set rdi for isDigit */
    call isDigit /* call isDigit function */
    cmpl $0, %eax /* check is char is digit */
    jz .LconsumeIntDone /* if not a digit, end loop */
    imulq $10, %r14 /* multiply pval by 10 */
    movq %rdi, %r10  /* move digit char into r10 */
    subq $48, %r10  /* subtract '0' from digit char to get numeric */
    addq %r10, %r14  /* add digit to pval */
    incq %r12 /* move pointer for s forward by one char */
    jmp .LconsumeIntTop /* loop again */
    
.LconsumeIntDone:
    movq %r12, %rax /* move updated pointer to return value */
    movq %r14, (%rsi) /* move pval value into pval pointer */
    popq %r14 /* pop r14 from stack */
    popq %r12 /* pop r12 from stack */
    addq $8, %rsp /* restore stack pointer */
    ret

/*
 * consumeOp - consume an operator character from the beginning of the
 * given C character string.
 *
 * Params:
 *   s - pointer to a nonempty C character string
 *   op - pointer to an int (32 bit signed integer) variable where the
 *        ASCII code of the first character of s should be stored
 *
 * Returns:
 *   a pointer to the second character of s
 */
	.globl consumeOp
consumeOp:
    subq $8, %rsp /* adjust stack pointer */
    movzbq (%rdi), %r10 /* get first char of s */
    movl %r10d, (%rsi) /* save first char of s in op */
    incq %rdi /* move pointer for s by one char */
    movq %rdi, %rax /* move updated pointer to return value */
    addq $8, %rsp /* restore stack pointer */
	ret

/*
 * stackPush - push a long (64 bit signed integer) value onto the stack.
 * Calls the fatalError function if the stack is full.
 * A full stack contains MAX_STACK (20) values.
 * If a value is successfully pushed on the stack, the count should
 * be incremented by 1.
 *
 * Params:
 *   stack - pointer to the beginning of the stack storage array
 *   count - pointer to a long variable storing the number of items
 *           currently on the stack
 *   val   - the value to push onto the stack
 *
 * Returns:
 *   nothing
 */
	.globl stackPush
stackPush:
    subq $8, %rsp /* adjust stack pointer */
    movq (%rsi), %r10 /* stores val of count in r10*/
    cmp $MAX_STACK, %r10 /* checks if stack is full */
    jge .LstackPushError /* if so throw error*/
    movq %rdx, (%rdi, %r10, 8) /* moves val into "top" of stack */
    incq (%rsi) /* increments count */
    jmp .LstackPushDone /* restores stack and returns */
.LstackPushError:
    movq $errorStackFull, %rdi /* moves error msg into first arg */
    call fatalError /* calls error to exit */
    jmp .LstackPushDone /* won't reach here */
.LstackPushDone:
    addq $8, %rsp /* restore stack pointer */
    ret

/*
 * stackPop - pops a long (64 bit signed integer) value from the stack.
 * Calls the fatalError function if the stack is empty.
 * If a value is successfully popped off the stack, the count should
 * be decremented by 1.
 *
 * Params:
 *   stack - pointer to the beginning of the stack storage array
 *   count - pointer to a long variable storing the number of items
 *           currently on the stack
 *
 * Returns:
 *   the value popped from the stack
 */
	.globl stackPop
stackPop:
    subq $8, %rsp /* adjust stack pointer */
    cmpq $0, (%rsi) /* check if count = 0 (empty stack) */
    jz .LstackPopError /* if so, throw error */
    decq (%rsi) /* reduce count by 1 to get index of last element */
    movq (%rsi), %r10 /* move value of count to r10 */
    movq (%rdi, %r10, 8), %rax /* move stack[count-1] to rax */
    jmp .LstackPopDone /* return last element */
.LstackPopError:
    movq $errorStackEmpty, %rdi /* move error message to rdi */
    call fatalError /* call the error function */
    jmp .LstackPopDone /* doesn't reach here */
.LstackPopDone:
    addq $8, %rsp /* restore stack pointer */
    ret

/*
 * evalOp - evaluate a computation by applying an operator to two operands.
 *
 * Params:
 *   op - the operator ('+', '-', '*', or '/')
 *   left - the left operand
 *   right - the right operand
 *
 * Returns:
 *   the result of applying the operator to the operands
 */
	.globl evalOp
evalOp:
    subq $8, %rsp /* adjust stack pointer */
    /* determine op */
    cmp $43, %rdi /* addition */
    jz .LevalOpAdd /* if so, add */
    cmp $45, %rdi /* subtraction */
    jz .LevalOpSub /* if so, subtract */
    cmp $42, %rdi /* multiplication */
    jz .LevalOpMult /* if so, multiply */
    cmp $47, %rdi /* division */
    jz .LevalOpDiv /* if so, divide */
    
    movq $0, %rdi /* won't reach here */
    jmp .LevalOpDone /* won't reach here */
.LevalOpAdd:
     movq %rsi, %r10 /* move left to r10 */
     addq %rdx, %r10 /* add right to left */
     movq %r10, %rax /* return the return value */
     jmp .LevalOpDone /* finish */
.LevalOpSub:
     movq %rsi, %r10 /* move left to r10 */
     subq %rdx, %r10 /* subtract right from left */
     movq %r10, %rax /* return the return value */
     jmp .LevalOpDone /* finish */
.LevalOpMult:
    movq %rsi, %r10 /* move left to r10 */
     imulq %rdx, %r10 /* multiply right by left */
     movq %r10, %rax /* return the return value */
     jmp .LevalOpDone /* finish */
.LevalOpDiv:
    movq %rsi, %rax /* move left to rax */
    movq %rdx, %r10 /* move right to r10 */
    cqto /* extend for sign bit */
    idivq %r10 /* divide left by right */
    jmp .LevalOpDone /* finish */
.LevalOpDone:
    addq $8, %rsp /* restore stack pointer */
	ret

/* vim:ft=gas:
 */
