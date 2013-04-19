LEX = flex
YACC = bison
YFLAGS = -d

objects = token.o parse.o

canal: $(objects)

token.o: token.l parse.h canal.h

parse.o: parse.y canal.h

clean:
	rm -f canal parse.h parse.c $(objects)

%.h: %.y
	$(YACC) $(YFLAGS) $<
	mv -f $(basename $<).tab.c $(basename $<).c
	mv -f $(basename $<).tab.h $(basename $<).h
