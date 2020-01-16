asmdoc : main.o
	$(CC) ${CFLAGS} -o asmdoc main.o -ll
	rm -f *.o vera_cs.c

clean:
	rm -f asmdoc
	
main.o : main.c
	lex -overa_cs.c vera_cs.lex
	${CC} ${CFLAGS} -o $@ -c $<

