! PROGRAM ZUMBASICFAILS
    INCLUDE JBC.h
    OPEN 'BASICFAILS' TO F.fails ELSE STOP 201,'BASICFAILS'
    cmd = SENTENCE(1)
    search_paths = FIELD(@SENTENCE, ' ', 3, 99)
    IF NOT(LEN(search_paths)) THEN
        CRT 'Syntax: ZUMBASICFAILS <editor> <search_paths>'
        STOP
    END ELSE
        EXECUTE 'jshow -c ':cmd CAPTURING io
        IF LEN(io) EQ 0 THEN
            CRT cmd:" doesn't appear to be a valid command"
            STOP
        END
    END
    CASING ON
    IF NOT(LEN(CHANGE(search_paths, '.',''))) THEN
        rc = GETCWD(pwd) 
        IF search_paths EQ '.' THEN
            search_paths = pwd
        END ELSE
            search_paths = FIELD(pwd, DIR_DELIM_CH, 0, COUNT(pwd, DIR_DELIM_CH))
        END
    END
    EXECUTE 'SSELECT BASICFAILS WITH *A1 "missing"' CAPTURING io

    found_locations = ''
    LOOP WHILE READNEXT prog DO
        prog = FIELD(prog, @TAB, DCOUNT(prog, @TAB))
        CRT 'Searching for ':prog:'...':
        EXECUTE @IM:'kfind ':search_paths:' -name ':DQUOTE(prog) CAPTURING found
        found = CHANGE(found, @AM, @VM)
        dc = DCOUNT(found, @VM)
        FOR d = dc TO 1 STEP -1
            dir = found<1, d>
            sc = COUNT(dir, DIR_DELIM_CH)
            dir = FIELD(dir, DIR_DELIM_CH, 1, sc)
            fname = FIELD(dir, DIR_DELIM_CH, sc)
            IF fname NE UPCASE(fname) THEN
                DEL found<1, d>
                CONTINUE
            END
            found<1, d> = dir
        NEXT d
        IF LEN(found) THEN
            CRT 'found in ':
            found_locations<1, -1> = prog
            found_locations<2, -1> = found
            found = CHANGE(found, @VM, ' ')
            CRT found
        END ELSE CRT 'not found'
    REPEAT
    EXECUTE 'SSELECT BASICFAILS WITH *A1 NE "missing"' CAPTURING io
    LOOP WHILE READNEXT path DO
        prog = FIELD(path, @TAB, DCOUNT(path, @TAB))
        fname = CHANGE(path[1, COL1()-1], @TAB, DIR_DELIM_CH)
        obj = fname:',OBJECT'
        OPEN obj TO F.obj THEN
            EXECUTE cmd:' ':fname:' ':prog
            IF prog 'R#2' EQ '.b' THEN
                k.obj = prog:'.o'
            END ELSE k.obj = '$':prog
            READV tmp FROM F.obj,k.obj,1 THEN
                DELETE F.fails, path
            END
        END ELSE
            CRT obj:' cannot be opened'
        END
    REPEAT
