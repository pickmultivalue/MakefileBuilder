! PROGRAM make
    INCLUDE JBC.h
#ifdef WIN32
    EXECUTE @IM:'knmake 2>&1' CAPTURING io
    IF LEN(io) EQ 0 THEN
        CRT 'Error: nmake not found in PATH'
        STOP
    END
    EXECUTE @IM:'knmake -f Makefile.WIN32 ':FIELD(@SENTENCE,' ',2, 999)
#else
    DONTCOMPILE
#endif
