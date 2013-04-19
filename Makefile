LEX = flex
YACC = bison
YFLAGS = -d

objects = token.o parse.o c.o 

c: $(objects)

token.o: token.l parse.h c.h

parse.o: parse.y c.h

clean:
	rm -f c parse.h parse.c $(objects)

%.h: %.y
	$(YACC) $(YFLAGS) $<
	mv -f $(basename $<).tab.c $(basename $<).c
	mv -f $(basename $<).tab.h $(basename $<).h
