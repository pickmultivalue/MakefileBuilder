! PROGRAM JUTIL_BASIC
    OPEN 'BASICFAILS' TO F.fails ELSE STOP 201,'BASICFAILS'
    CLEARFILE F.fails
    proglist = ''
    LOOP WHILE READNEXT prog DO proglist<-1> = prog REPEAT
    IF LEN(proglist) THEN
        EXECUTE 'JUTIL_CATEXEC BASIC' PASSLIST proglist
    END ELSE
        EXECUTE 'JUTIL_CATEXEC BASIC'
    END
