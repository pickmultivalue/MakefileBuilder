    FUNCTION fnPARSESOURCE(convertFiles, fname, F.var, K.file, xref, error)
!
    INCLUDE JBC.h
    DEFFUN fnPARSESOURCE()
    DEFFUN fnOPEN()
    DEFFUN fnCONVBP2DIR()
!
    COMMON /fnPARSESOURCE/ include_strings, jbase_includes
    comments = '!*'
    CASING ON
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
            error<2, -1> = fname:',':K.file
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
                    IF convertFiles AND NOT(fnCONVBP2DIR(incl_file, f.var)) THEN
                        CRT incl_file:' is not a directory'
                        error<1, -1> = incl_file
                    END
                END
                incl_key = incl_file:DIR_DELIM_CH:K.incl
                LOCATE incl_key IN xref<1> BY 'AL' SETTING fpos ELSE
                    INS incl_key BEFORE xref<1,fpos>
                    INS '' BEFORE xref<2,fpos>
                END
!
                IF NOT(fnPARSESOURCE(convertFiles, incl_file, F.incl, K.incl, xref, error)) THEN
                    LOCATE K.file IN xref<2,fpos> BY 'AL' SETTING ipos ELSE
                        INS K.file BEFORE xref<2,fpos,ipos>
                    END
                END
            END
        END ELSE
            line = CHANGE(TRIM(line), ' ', @AM)
            IF NOT(LEN(line)) THEN CONTINUE
            fword = UPCASE(line<1>)
            IF fword EQ 'REM' THEN CONTINUE
            LOCATE 'DEFFUN' IN line SETTING cpos ELSE
                LOCATE 'CALL' IN line SETTING cpos ELSE
                    LOCATE 'call' IN line SETTING cpos ELSE cpos = @FALSE
                END
            END
            IF cpos THEN
                subr = FIELD(line<cpos+1>, '(', 1)
                LOCATE subr IN xref<3> BY 'AL' SETTING cpos ELSE
                    INS subr BEFORE xref<3,cpos>
                END
                CONTINUE
            END
            LOCATE 'EXECUTE' IN line SETTING cpos THEN
                exec = line<cpos+1>
                IF INDEX(\"'\, exec[1,1], 1) THEN
                    q = exec[1,1]
                    exec = FIELD(exec, q, 2)
                    IF exec[1,1] EQ '!' THEN CONTINUE
                    LOCATE exec IN xref<4> BY 'AL' SETTING cpos ELSE
                        INS exec BEFORE xref<4,cpos>
                    END
                END
            END
        END
    NEXT l
!
    RETURN (@TRUE)
