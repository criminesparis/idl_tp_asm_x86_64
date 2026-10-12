# int64_t callgcd(int64_t x, int64_t y)
# x86-64, syntaxe AT&T, convention System V: x -> %rdi, y -> %rsi
# résultat dans %rax.

#ifdef __APPLE__
# define C(sym) _##sym
#else
# define C(sym) sym
#endif

    .text
    .globl C(callgcd)
C(callgcd):
    # x -> %rdi, y -> %rsi

.Lloop:
    cmpq    %rsi, %rdi      
    je      .Lend           # Si x == y, sortir de la boucle

    jle     .Lelse    
  

    # Bloc IF : x > y
    subq    %rsi, %rdi      # x = x - y
    jmp     .Lloop          

.Lelse:
    # Bloc ELSE
    subq    %rdi, %rsi      # y = y - x
    jmp     .Lloop         

.Lend:
    movq    %rdi, %rax     
    ret                    


