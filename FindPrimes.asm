TITLE FindPrimes.asm
;===================================================================================
; Author:  Tobby Lie
; Date:  5 April 2018
; Description: This program utilizes the Sieve of Eratosthenes to find all prime numbers
; in a range from 2 to n (n <= 1000), n inputted from the user
;
; Last updated: 4/11/18 1:34PM
; ====================================================================================

Include Irvine32.inc 

; ====================================================================================
;// PROTO
ClearRegisters proto							;// ClearRegisters
; ====================================================================================
userInput proto,								;// userInput
ptrInput:ptr dword
; ====================================================================================
fillInts proto,									;// fillInts
ptrlistOfInts:ptr dword
; ====================================================================================
findPrimes proto,								;// findPrimes
ptrIntList:ptr dword
; ====================================================================================
printList proto,								;// printList
ptrPrintArray:ptr dword,
ptrIntList1:ptr dword,
valnInput1:dword,
; ====================================================================================
printPrimes proto,								;// printPrimes
ptrprintArray1:ptr dword,
valnInput2:dword,
; ====================================================================================
clearPrintArray proto,
ptrprintArray2:ptr dword
; ====================================================================================
;//Macros
ClearEAX textequ <mov eax, 0>
ClearEBX textequ <mov ebx, 0>
ClearECX textequ <mov ecx, 0>
ClearEDX textequ <mov edx, 0>
ClearESI textequ <mov esi, 0>
ClearEDI textequ <mov edi, 0>
; ====================================================================================
.data
; ====================================================================================
Menuprompt byte 'MAIN MENU', 0Ah, 0Dh,			;// Menu prompt is one string
'==========', 0Ah, 0Dh,
'1. Enter number n:', 0Ah, 0Dh,
'2. Display all primes between 2 and n: ',0Ah, 0Dh,
'3. Exit: ',0Ah, 0Dh, 0h
nInput dword 0h									;// user input for n
listOfInts dword 1001d dup(0)					;// holds integers 0 - 1000
printArray dword 168d dup(0)					;// holds primes to be printed, 168 because there are 168 possible primes between 2 - 1000		
useroption byte 0h		
errormessage byte 'You have entered an invalid option. Please try again.', 0Ah, 0Dh, 0h			;//Error message
; ====================================================================================
.code
; ====================================================================================
main PROC
; ====================================================================================

invoke ClearRegisters							 ;// clears registers

begin:

call clrscr
mov edx, offset menuprompt						 ;// menu prompt
call WriteString
call readhex
mov useroption, al								 ;// readhex holds input in al and will then be moved into useroption

opt1:											 ;// Ask user for string input
cmp useroption, 1
jne opt2
call clrscr
invoke userInput, addr nInput					 ;// call for user input
jmp begin

opt2:											;// Convert all letters to lower case
cmp useroption, 2
jne opt3
call clrscr
invoke fillInts, addr listOfInts				;// call for listOfInts to be filled
invoke findPrimes, addr listOfInts				;// find primes in listOfInts
call clrscr
invoke printList, addr printArray, addr listOfInts, nInput	;// form array of primes between 2 and n
invoke printPrimes, addr printArray, nInput		;// print contents of printArray
jmp begin

opt3:											;// remove all non letter elements
cmp useroption, 3
jne oops
jmp quitit

oops:											 ;// error message for invalid input
push edx
mov edx, offset errormessage
call writestring
call waitmsg
pop edx
jmp begin

quitit:											;// quit program

exit
; ====================================================================================
main ENDP
; ====================================================================================
;// Procedures
; ====================================================================================
clearPrintArray proc,
ptrprintArray2:ptr dword
;// Description:  clears string ebx points to 
;// Requires:  ebx esi ecx
;// Returns:  string ebx points to cleared out
mov esi, 0
mov ecx, 168d
mov ebx, ptrprintArray2
clearstr:										;// loop through every single element of string and fill with 0
mov dword ptr [ebx+esi], 0
add esi, 4
loop clearstr
ret
clearPrintArray endp
; ====================================================================================
ClearRegisters Proc
;// Description:  Clears the registers EAX, EBX, ECX, EDX, ESI, EDI
;// Requires:  Nothing
;// Returns:  Nothing, but all registers will be cleared.

cleareax
clearebx
clearecx
clearedx
clearesi
clearedi

ret
ClearRegisters ENDP
; ====================================================================================
printPrimes proc,
ptrprintArray1:ptr dword,
valnInput2:dword,
;// Description:  Prints contents of printArray which holds primes between 2 and n
;// Requires:  ebx, eax, edx, ecx
;// Returns:  Nothing, but all primes between 2 and n will be printed
.data
;// messages 
primesMessage byte 'There are ' , 0h			
primesMessage2 byte ' prime(s) between 2 and n (n = ' , 0h
primesMessage3 byte ')' , 0Ah, 0Dh, 0h
line byte '==========================================' , 0Ah, 0Dh, 0h	;// to separate message from primes
.code

mov ebx, ptrprintArray1					;// mov address of printArray into ebx
mov eax, valnInput2						;// mov value of nInput into eax


mov edx, offset primesMessage			;// display messages
call writeString
push eax
mov eax, ecx
call writeDec					
pop eax
mov edx, offset primesMessage2
call writeString
call writeDec
mov edx, offset primesMessage3
call writeString
mov edx, offset line
call writeString

mov edx, 0								;// set up for gotoxy
mov dh, 1
mov esi, 0								;// set up esi for indexing							;

newRow:									;// loop to this when a new row needs to be formed
inc dh									;// increment the y coordinate
mov dl, 0								;// reset x coordinate

Columns:
call Gotoxy
mov eax, [ebx + esi]
call writeDec
add esi, 4								;// increment by 4 since dword
dec ecx									;// to compare against 0
add dl, 5
push ecx
push eax
mov eax, [ebx + esi]
mov ecx, 0
cmp eax, ecx							;// if next element in array is 0 then quit
je toEnd
pop eax
pop ecx									;// need to add 5 spaces for columns
mov eax, 0
cmp ecx, eax							;// if ecx is zero this means we can exit since there are no more elements to go through
je toEnd

mov al, 25							
cmp dl, al								;// if 5 elements in a row already, need to create new row
ja newRow
jmp Columns

toEnd:
call crlf
call waitmsg
invoke clearPrintArray, ptrprintArray1	;// clear printArry so that it can be reused for another set of primes

ret
printPrimes endp
; ====================================================================================
printList proc,
ptrPrintArray:ptr dword,
ptrIntList1:ptr dword,
valnInput1:dword
;// Description:  Create array of primes from 2 to n in order to easily print array
;// Requires:  ebx, eax, edx, ecx, edi, esi
;// Returns:  printArray will be filled with elements
.data
count dword 0
maxSize dword 0
.code
mov ebx, ptrPrintArray					 ;// mov arguments over to registers
mov edx, ptrIntList1
mov eax, valnInput1

mov esi, 0
mov edi, 0
push edx
push eax
push edi
mov edi, 4
mul edi
mov maxSize, eax						;// get maxSize which is the number that indexing cannot exceed
pop edi
pop eax
pop edx
	
mov esi, 0								;// prepare esi and edi for indexing
mov edi, 0

fill:
mov ecx, [edx + esi]					
cmp esi, maxSize						;// if past last index then go to end
ja goToEnd
cmp ecx, 0
je skipOver								;// if the element is 0 then it does not need to be added to printArray
mov [ebx + edi], ecx
add edi, 4
inc count								;// however if an element has been added to array then count needs to be tracked
skipOver:
add esi, 4
jmp fill
goToEnd:
mov ecx, count			
mov count, 0							;// reset count

ret
printList endp
; ====================================================================================
findPrimes proc,
ptrIntList:ptr dword
;// Description:  For any element that is not prime in listOfInts, replace with zero
;// Requires:  ebx, eax, edx, ecx, esi, edi
;// Returns:  Nothing, but listOfInts is updated and now only has primes
.data 
currentMultiple dword 0					;// variables to aid in keeping track of position and also knowing what we need to increment by to get rid of non primes
currentPos dword 0
.code
mov ebx, ptrIntList						;// mov arguments to registers

mov esi, 8								;// start at 2 since 0 and 1 do not matter
mov edx, 0
mov ecx, 31								;// square root of 1000d
outLoop:
mov eax, [ebx + esi]
mov currentPos, esi
cmp eax, 0								;// if eax is 0 then no need to use it
je skip

mov edi, [ebx + esi]					;// create the currentMultiple which will determine how much to increment by
mov eax, edi
mov edx, 4
mul edx
mov edi, eax
mov currentMultiple, eax

inLoop:
add edi, currentMultiple				;// Use current multiple to eliminate all multiples of a prime

mov edx, 0
mov [ebx + edi], edx					;// replace non primes with zero

cmp edi, 4004d							;// if element exceeds 1000d then you need to leave this loop
ja skip
jmp inLoop

skip:
add esi, 4								;// mov index up one, 4 because dword
loop outLoop

ret
findPrimes endp
; ====================================================================================
fillInts proc,
ptrlistOfInts:ptr dword
;// Description:  fill listOfInts with ints 0-1000
;// Requires:  eax, ecx, edi
;// Returns:  Nothing, but listOfInts will be be filled with ints
mov eax, ptrlistOfInts					;// mov arguments to registers

mov ecx, 1001d							;// prepare for loop
mov esi, 0
mov edi, 0
fillLoop:
mov [eax + esi], edi
inc edi
add esi, 4
loop fillLoop 

mov edi, 0								;// second element is 1, so because we are not considering it for primes, we replace with 0
mov [eax + 4], edi
ret
fillInts endp
; ====================================================================================
userInput proc,
ptrInput:ptr dword
;// Description:  ask user for input of n
;// Requires:  eax, edi, edx, 
;// Returns:  nInput
.data
userPrompt byte 'Please input a number n that represents the range of numbers from 2 and n (n must be <= 1000 and n must be >=2): ' , 0Ah, 0Dh, 0h
error byte 'Your input is too either too large or too small! Try again (n must be <= 1000 and n must be >=2): ' , 0Ah, 0Dh, 0h
.code

mov edi, ptrInput						;// mov arguments to registers

again:									;// if error occurs

continue:
mov edx, offset userPrompt
call writeString

call readDec							;// eax holds n

cmp eax, 2
jb errorPortion							;// check if input is in bounds of 2 - 1000
cmp eax, 1000
ja errorPortion
jmp over

errorPortion:
mov edx, offset error					;// error message
call writeString
jmp again

over:
mov [edi], eax							;// mov user n into nInput
call waitmsg

ret
userInput endp
; ====================================================================================

; ====================================================================================
END main
; ====================================================================================