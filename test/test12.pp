union wait {
	int w_status;

	struct {
		unsigned int w_Termsig:7, w_Coredump:1, w_Retcode:8, w_Filler:16;
	} w_T;

	struct {
		unsigned int w_Stopval:8, w_Stopsig:8, w_Filler:16;
	} w_S;

};
