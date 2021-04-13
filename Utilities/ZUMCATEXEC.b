! PROGRAM ZUMCATEXEC
    INCLUDE JBC.h
    DEFFUN fnGETCATS()
    DEFFUN fnSPLITSENT()
    DEFFUN fnTIMESTAMP()
    cmd = FIELD(@SENTENCE,' ', 2, 1)
    args = FIELD(@SENTENCE,' ', 3, 99)
    arg1 = FIELD(args, ' ', 1)
    fnames = fnGETCATS(arg1)
    fc = DCOUNT(fnames<1>, @VM)
    OPEN 'BASICFAILS' TO F.fails ELSE STOP 201,'BASICFAILS'
    CRT 'Processing ':DQUOTE(cmd):' on the following files: ':
    CRT CHANGE(fnames<1>, @VM, ', ')
    CRT
    options = ''
    foldCount = 100
    CASING ON
    BEGIN CASE
        CASE cmd EQ 'BASIC'
            foldCount = 1 
        CASE cmd EQ 'CATALOG'
            options = ' (O'
    END CASE
    result = ''
    objinfo = ''
    srcinfo = '' 
    errors = @FALSE
    FOR f = 1 TO fc
        fname = fnames<1, f>
        obj = fname:',OBJECT'
        OPEN obj TO F.object ELSE STOP 201,obj
        rc = IOCTL(F.object, JIOCTL_COMMAND_FILESTATUS, result)
        IF result<1> NE 'UD' THEN
            CRT obj:' is not a directory'
            errors = @TRUE
        END
        OPEN fname TO F.source THEN
            rc = IOCTL(F.source, JIOCTL_COMMAND_FILESTATUS, result)
            IF result<1> NE 'UD' THEN
                CRT fname:' is not a directory'
                errors = @TRUE
            END
        END ELSE
            CRT 'Unable to open ':SQUOTE(fname)
            errors = @TRUE
        END
    NEXT f
    IF errors THEN STOP
    FOR f = 1 TO fc
        fname = fnames<1, f>
        obj = fname:',OBJECT'
        OPEN obj TO F.object ELSE STOP 201,obj
        rc = IOCTL(F.object, JBC_COMMAND_GETFILENAME, objinfo)
        OPEN fname TO F.source THEN
            IF cmd EQ 'BASIC' THEN CLEARFILE F.object
            rc = IOCTL(F.source, JBC_COMMAND_GETFILENAME, srcinfo)
            progs = fnSPLITSENT(fnames<2, f>, foldCount)
            pc = DCOUNT(progs, @AM)
            FOR p = 1 TO pc
                fold_progs = CHANGE(progs<p>, ' ', @AM)
                tc = DCOUNT(fold_progs, @AM)
                FOR t = tc TO 1 STEP -1
                    prog = fold_progs<t>
                    IF prog 'R#2' EQ '.b' THEN
                        k.obj = prog:'.o'
                    END ELSE k.obj = '$':prog
                    fpath = fname:DIR_DELIM_CH:prog

                    BEGIN CASE
                        CASE cmd EQ 'CHECKBAS'
                            IF NOT(IOCTL(F.source, JIOCTL_COMMAND_FINDRECORD, prog)) THEN
                                CRT fpath:' missing'
                                CONTINUE
                            END
                            fullpath = objinfo:DIR_DELIM_CH:k.obj
                            objstamp = fnTIMESTAMP(fullpath) 
                            IF LEN(objstamp) THEN
                                fullpath = srcinfo:DIR_DELIM_CH:prog
                                srcstamp = fnTIMESTAMP(fullpath)
                                IF objstamp<1> GE srcstamp<1> AND objstamp<2> GE srcstamp<2> ELSE
                                    CRT fpath:' source is newer than object'
                                END
                            END ELSE
                                CRT fpath:' not compiled'
                            END
                        CASE cmd EQ 'BASIC'
                            DELETE F.source, k.obj
                    END CASE
                    READV tst FROM F.source,prog,1 ELSE
                        DEL fold_progs<t>
                        tc--
                        CRT SQUOTE(prog):' missing from ':SQUOTE(fname)
                        WRITE 'missing' ON F.fails, CHANGE(fname:'/':prog, '/', @TAB)
                    END
                NEXT t
                IF NOT(tc) THEN CONTINUE
                this_progs = CHANGE(fold_progs, @AM, ' ')
                BEGIN CASE
                    CASE cmd EQ 'CHECKBAS'
                    CASE 1
                        CRT 'Processing ':fname:' ':this_progs
                        EXECUTE cmd:' ':fname:' ':this_progs:options RETURNING errs
                        IF cmd EQ 'CATALOG' THEN
                            IF errs NE 241 THEN DEBUG
                        END ELSE
                            IF errs<1,3> NE 'BASIC_OK' THEN
                                WRITE errs ON F.fails, CHANGE(fname:'/':this_progs, '/', @TAB)
                            END
                        END
                END CASE
            NEXT p
        END
    NEXT f
