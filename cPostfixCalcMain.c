/*
 * main function for C and assembly language versions of the
 * postfix calculator. You shouldn't need to modify this file.
 */

#include <stdio.h>
#include <stdlib.h>
#include "cPostfixCalc.h"

int main(int argc, char **argv) {
  if (argc != 2) {
    printf("Wrong number of arguments\n");
    return 1;
  }
  const char *s = argv[1];
  long result = eval(s);
  printf("Result is: %ld\n", result);
  return 0;
}
