/*
 * postfix calculator (assembly language version)
 * eval function implementation
 */

.equ TOK_INT, 0
.equ TOK_OP, 1
.equ TOK_UNKNOWN, 2
.equ MAX_STACK, (20 * 8)

	.section .rodata

	.section .text
errorInvalid:
	.string "Invalid expression"
/*
 * eval - evaluate a postfix expression
 * Should directly or indirectly call fatalError if the expression is invalid.
 *
 * Params:
 *   s - C string containing a postfix expression
 *
 * Returns:
 *   the result of evaluating the expression
 */
	.globl eval
eval:
    pushq %rbp
    pushq %r12 /* push r12 to stack */
    pushq %r13 /* push r13 to stack */
    pushq %r14 /* push r14 to stack */
    pushq %r15 /* push r15 to stack */
    subq $8, %rsp  /* integer value produced by consumeInt, and operator for consumeOp */
    subq $8, %rsp  /* stack count */ 
    subq $MAX_STACK, %rsp /* adjust stack pointer to length of 'stack'*/
    movq %rsp, %rbp

    /*
     * Local variables:
     *    0(%rbp) - stack array
     *    160(%rbp) - stack count
     *    168(%rbp) - (long) integer value or operator
     */

    movq $0, 160(%rbp) /* initializes the count to 0 */
    call skipws /* skip spaces, s val in rax*/
    jmp .LevalTop /* begin looping through s */
    
    
.LevalTop:
    movq %rax, %rdi /* move s from rax back to rdi */
    cmp $0, %rdi /* check if s is null */
    jz .LevalCheckCount /* if so, end loop */
    movq %rdi, %r12 /* save s in r12 so tokenType doesn't lose it */
    call tokenType /* determine if operand or operator (stored in %rax) */
    cmp $TOK_UNKNOWN, %rax /* check for bad char */
    jz .LevalError /* throw error */
    cmp $TOK_OP, %rax /* check if operator */
    jz .LevalOp /* if so, process op */ 
    cmp $TOK_INT, %rax /* check if digit */
    jz .LevalInt /* if so, process digit */

.LevalError:
    movq $errorInvalid, %rdi /* set input of fatal error to error message */
    call fatalError /* call error */
    jmp .LevalDone /* won't reach here */

.LevalOp:
    movq %r12, %rdi /* move s back to rdi */
    leaq 168(%rbp), %rsi /* moves operator pointer into second arg */
    call consumeOp /* s in rax, op in rsi */
    movq %rax, %r12 /* move s from rax to r12 temporarily */
    leaq 0(%rbp), %rdi /* move stack pointer to rdi */
    leaq 160(%rbp), %rsi /* moves counter pointer to rsi */
    call stackPop /* pop, operand 1 in rax, count in rsi*/
    movq %rax, %r14 /* move right operand from rax to r14 temporarily */
    leaq 0(%rbp), %rdi /* move stack pointer to rdi */
    leaq 160(%rbp), %rsi /* moves counter pointer to rsi */
    call stackPop /* pop, operand 1 in rax, count in rsi*/
    movq %rax, %r15 /* move left operand from rax to r15 temporarily */
    movq 168(%rbp), %rdi /* move op to rdi */
    movq %r15, %rsi /* move left to rsi */
    movq %r14, %rdx /* move right to rdx */
    call evalOp /* evaluate left operand right, result in rax*/
    leaq 0(%rbp), %rdi /* move stack to rdi */
    leaq 160(%rbp), %rsi /* moves count into second arg*/
    movq %rax, %rdx /* move result to rdx */
    call stackPush /* push result to stack*/
    movq %r12, %rdi /*move s to rdi */
    call skipws /* skip spaces */
    jmp .LevalTop /* loop again */

.LevalInt:
    movq %r12, %rdi /* move s back to rdi */
    leaq 168(%rbp), %rsi /* moves int pointer into second arg */
    call consumeInt /* new s will be in %rax, new num will be in %rsi */
    movq %rax, %r12 /* move s temporarily to r12*/
    movq 168(%rbp), %rdx /* moves int pointer into third arg */
    leaq 160(%rbp), %rsi /* moves count pointer into second arg */
    leaq 0(%rbp), %rdi /* move stack to rdi */ 
    call stackPush /* count in rsi */
    movq %r12, %rdi /* move s back to rdi */
    call skipws /* skip spaces */
    jmp .LevalTop /* loop again */

.LevalCheckCount:
    cmpq $1, 160(%rbp)/* check if 'stack' only has 1 value */
    jz .LevalMoveAnswer /* if so, done */
    movq $errorInvalid, %rdi /* set input of fatal error to error message */
    call fatalError /* call error */
    jmp .LevalDone /* won't reach here */

.LevalMoveAnswer:
    leaq 0(%rbp), %rdi /* move stack pointer to rdi */
    leaq 160(%rbp), %rsi /* moves counter pointer to rsi */
    call stackPop /* answer in rax */
    jmp .LevalDone /* return result */

.LevalDone:
    addq $8, %rsp /* restores stack */
    addq $8, %rsp /* restores stack */
    addq $MAX_STACK, %rsp /* restore stack pointer */
    popq %r15 /* pop r15 from stack */
    popq %r14 /* pop r14 from stack */
    popq %r13 /* pop r13 from stack */
    popq %r12 /* pop r12 from stack */
    popq %rbp
	ret

/* vim:ft=gas:
 */
