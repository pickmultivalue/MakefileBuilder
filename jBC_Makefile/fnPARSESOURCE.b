    FUNCTION fnPARSESOURCE(fname, F.var, K.file, xref, error)
!
    INCLUDE JBC.h
    DEFFUN fnPARSESOURCE()
    DEFFUN fnOPEN()
!
    COMMON /fnPARSESOURCE/ include_strings, jbase_includes
    comments = '!*'
!
    IF UNASSIGNED(include_strings) OR LEN(include_strings) EQ 0 THEN
        include_strings = ''
        include_strings<-1> = 'INCLUDE'
        include_strings<-1> = '$INCLUDE'
        include_strings<-1> = '$INSERT'
    END
    IF UNASSIGNED(jbase_includes) OR LEN(jbase_includes) EQ 0 THEN
        jbase_includes = ''
        OPEN SYSTEM(1011):DIR_DELIM_CH:'include' TO F.jbcincludes THEN
            SELECT F.jbcincludes
            LOOP WHILE READNEXT incid DO
                jbase_includes<-1> = incid
            REPEAT
        END
    END
    IF UNASSIGNED(error) THEN error = ''
!
    bas_suffix = '.b'
    READ source FROM F.var, K.file:bas_suffix THEN
        K.file := bas_suffix
    END ELSE
        READ source FROM F.var, K.file ELSE
            error<2, -1> = K.file
            RETURN(@FALSE)
        END
    END
    sc = DCOUNT(source, @AM)
    FOR l = 1 TO sc
        line = TRIM(source<l>)
        IF INDEX(comments, line[1,1], 1) THEN CONTINUE
        FOR w = 1 TO 2
            word = FIELD(line, ' ', w)
            LOCATE word IN include_strings SETTING ipos THEN
                BREAK
            END ELSE ipos = @FALSE
        NEXT w
        IF ipos THEN
            incl1 = FIELD(line, ' ', w + 1)
            LOCATE incl1 IN jbase_includes SETTING jpos THEN CONTINUE
            incl2 = FIELD(line, ' ', w + 2)
            IF LEN(incl2) THEN
                incl_file = incl1
                K.incl = incl2
            END ELSE
                incl_file = fname
                K.incl = incl1
            END
            IF NOT(fnOPEN(incl_file, F.incl, '':@AM:@TRUE)) THEN
                error<1, -1> = incl_file
            END ELSE
                status = ''
                rc = IOCTL(F.incl, JIOCTL_COMMAND_FILESTATUS, status)
                IF status<1> NE 'UD' THEN
                    CRT incl_file:' is not a directory'
                    error<1, -1> = incl_file
                END
                incl_key = incl_file:DIR_DELIM_CH:K.incl
                LOCATE incl_key IN xref<1> BY 'AL' SETTING fpos ELSE
                    INS incl_key BEFORE xref<1,fpos>
                    INS '' BEFORE xref<2,fpos>
                END
!
                IF NOT(fnPARSESOURCE(incl_file, F.incl, K.incl, xref, error)) THEN
                    LOCATE K.file IN xref<2,fpos> BY 'AL' SETTING ipos ELSE
                        INS K.file BEFORE xref<2,fpos,ipos>
                    END
                END
            END
        END
    NEXT l
!
    RETURN (@TRUE)
