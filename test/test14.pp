typedef struct symrec {
	char *name;
} symrec;

symrec *put_sym(const char *sym_name, int sym_type) {
	ptr->name = (char *) malloc (strlen (sym_name) + 1);
	ptr->next = (symrec *)sym_table;
	return ptr;
}
