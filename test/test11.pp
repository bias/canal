enum months {JAN = 1, FEB};
enum months m;

typedef struct blah {
	int a;
	enum months b;
} blah;


main() {
	blah.b = FEB;
	return blah.b;
}
