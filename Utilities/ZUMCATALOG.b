! PROGRAM ZUMCATALOG
    progs = FIELD(@SENTENCE, ' ', 2, 999)
    proglist = ''
    IF progs NE 'BINS' AND progs NE 'LIBS' THEN
        IF LEN(progs) THEN 
            proglis = CHANGE(progs, ' ', @AM)
        END 
    END
    IF progs NE 'LIBS' THEN
        CRT 'Processing bins'
        CRT '==============='
        DATA 'ZUMCATEXEC CATALOG BINS'
        IF LEN(proglist) THEN
            EXECUTE 'SELECT ZUMCATS' PASSLIST proglist
        END ELSE
            EXECUTE 'SELECT ZUMCATS'
        END
    END
    IF progs NE 'BINS' THEN
        CRT 'Processing libs'
        CRT '==============='
        DATA 'ZUMCATEXEC CATALOG LIBS'
        IF LEN(proglist) THEN
            EXECUTE 'SELECT ZUMLIBS' PASSLIST proglist
        END ELSE
            EXECUTE 'SELECT ZUMLIBS'
        END
    END
