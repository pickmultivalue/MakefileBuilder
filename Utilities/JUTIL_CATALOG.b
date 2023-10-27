! PROGRAM JUTIL_CATALOG
    progs = FIELD(@SENTENCE, ' ', 2, 999)
    proglist = ''
    IF progs NE 'BINS' AND progs NE 'LIBS' THEN
        IF LEN(progs) THEN
            proglis = CHANGE(progs, ' ', @AM)
        END ELSE
            LOOP WHILE READNEXT prog DO proglist<-1> = prog REPEAT
        END
    END
    IF progs NE 'LIBS' THEN
        CRT 'Processing bins'
        CRT '==============='
        DATA 'JUTIL_CATEXEC CATALOG BINS'
        IF LEN(proglist) THEN
            EXECUTE 'SELECT JUTLCATS' PASSLIST proglist
        END ELSE
            EXECUTE 'SELECT JUTLCATS'
        END
    END
    IF progs NE 'BINS' THEN
        CRT 'Processing libs'
        CRT '==============='
        DATA 'JUTIL_CATEXEC CATALOG LIBS'
        IF LEN(proglist) THEN
            EXECUTE 'SELECT JUTLLIBS' PASSLIST proglist
        END ELSE
            EXECUTE 'SELECT JUTLLIBS'
        END
    END
