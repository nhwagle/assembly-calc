/*
 * Common header file for C version of postfix calculator:
 * these definitions also pertain to the assembly language
 * functions, since they are required to be behaviorally
 * identical to the C functions
 */

#ifndef CPOSTFIXCALC_H
#define CPOSTFIXCALC_H

/* Maximum operand stack depth */
#define MAX_STACK   20

/* Token types */
#define TOK_INT     0
#define TOK_OP      1
#define TOK_UNKNOWN 2

long addPositive(long a, long b); /* example function */

/* TODO: Add prototypes for your postfix calculator functions */
void fatalError(const char *msg) __attribute__((noreturn));
int isSpace(int c);
int isDigit(int c);
const char *skipws(const char *s);
int tokenType(const char *s);
const char *consumeInt(const char *s, long *val);
const char *consumeOp(const char *s, int *op);
void stackPush(long stack[], long *count, long val);
long stackPop(long stack[], long *count);
long evalOp(int op, long left, long right);
long eval(const char *s);

#endif /* CPOSTFIXCALC_H */
