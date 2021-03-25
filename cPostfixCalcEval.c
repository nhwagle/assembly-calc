#include <stdio.h>
#include <stdlib.h>
#include "cPostfixCalc.h"

#include <string.h>

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
long eval(const char *s) {

  /* Note: this function should be implemented by calling functions
   * declared in cPostfixCalc.h and defined in cPostfixCalcFuncs.c
   */  
    long values[MAX_STACK];
	long count = 0;
    
    // get rid white space
    s = skipws(s);
    

    while(s[0] != '\0'){ // loop until end of expression
        
        // check if current char is a space
        if(!isSpace(s[0])){
            int token = tokenType(s); // determine if operand or operator (or none)
            if(token == TOK_INT){
                long num;
                s = consumeInt(s, &num); // identify value
                stackPush(values, &count, num); // add value to stack
            } else if(token == TOK_OP){
                int op;
                s = consumeOp(s, &op); // identify operator
                long right = stackPop(values, &count); // get right operand
                long left = stackPop(values, &count); // get left operand
                long result = evalOp(op, left, right); // calculate result
                stackPush(values, &count, result); // add result to stack
                
            } else{ // character is invalid
                fatalError("Invalid expression");
            }
        } else { // char is a space, move forward by one char
            s++;
        }
    }
    // checks if stack has only 1 value
    if(count == 1){ 
        return stackPop(values, &count);
    } else{ // stack has no or more than one values, invalid
        fatalError("Invalid expression");
    }
}
