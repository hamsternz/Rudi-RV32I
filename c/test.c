/******************************************************************************
# test.c  - A test C programm
#
# Part of the Rudi-RV32I project
#
# See https://github.com/hamsternz/Rudi-RV32I
#
# MIT License
#
###############################################################################
#
# Copyright (c) 2020 Mike Field
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
******************************************************************************/

char text[] = "Hello world!\r\n";
char az[] = "Text ";  
char bz[] = " characters long\r\n";  

int putchar(int c) {
  volatile char * serial           = (char *)0xE0000000;
  volatile char * serial_tx_status = (char *)0xE0000004;

  // Wait until status is zero 
  while(*serial_tx_status) {
  }

  // Output character
  *serial = c;
  return c;
}

int puts(char *s) {
    int n = 0;
    while(*s) {
      putchar(*s);
      s++;
      n++;
    } 
    return n;
}

int mylen(char *s) {
    int n = 0;
    while(*s) {
      s++;
      n++;
    } 
    return n;
}

int test_program(void) {
  puts("System restart\r\n");  
  while(1) {
    puts("String is ");
    putchar('0'+mylen(az));
    puts(" characters long\r\n");

    puts(az);
    putchar('0'+mylen(az));
    puts(bz);
  }
  return 0;
}
