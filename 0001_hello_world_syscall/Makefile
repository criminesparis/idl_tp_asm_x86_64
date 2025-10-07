hello_world_syscall: hello_world_syscall.o
	ld -o $@ $<
hello_world_syscall.o: hello_world_syscall.s
	gcc -g -no-pie -o $@ -c $<
clean:
	rm -f *.o hello_world_syscall
