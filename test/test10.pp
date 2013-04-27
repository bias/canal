enum months {JAN = 1, FEB};
enum months m;

typedef struct blah {
	int a;
	enum months b;
};

blah bl;

main() {
	bl.b = FEB;
	return bl.b;
}
