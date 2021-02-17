! PROGRAM ZUMGETCATS
!
    INCLUDE JBC.h
    CALL JBASEParseCommandLine1(args, opts, sent)
!
    LOCATE '-l' IN args SETTING local ELSE local = @FALSE
!
    DEFFUN fnOPEN()
    DEFFUN fnLAST()
    DEFFUN fnTRIMLAST()
    DEFFUN fnDECODE()
!
    DIM A.cat(3)
    EQU A.fname     TO A.cat(1)
    EQU A.fpath     TO A.cat(2)
    EQU A.timestamp TO A.cat(3)
!
    rc = fnOPEN('ZUMCATS', F.catalog, 1)
    rc = fnOPEN('BADCATS', F.badcatalog, 1)
    CLEARFILE F.catalog
    CLEARFILE F.badcatalog
    badcount = 0
!
    ksh = @IM:'k'
!
! Look through PATH to find .so files
! (which would be the shared object version of a cataloged program)
!
    win = INDEX(SYSTEM(1017), 'WIN', 1)
    IF win THEN
        libdef = 'libdef'
        find = 'jfind'
        devnull = 'NUL'
!        EXECUTE 'jshow -c find' CAPTURING io
!        IF LEN(io) EQ 0 THEN
!            CRT 'Please install cygwin tools'
!            CRT
!            CRT 'You will need: find, make'
!            STOP
!        END
    END ELSE
        libdef = 'lib' 
        find = 'find' 
        devnull = '/dev/null' 
    END
    IF local THEN
        rc = GETCWD(pwd)
        paths = pwd:DIR_DELIM_CH:'bin'
    END ELSE
        rc = GETENV('PATH', paths)
    END
    findArgs = ' -name "*':FILE_SUFFIX_SO:' -print" 2>':devnull 
    findBins = find:' ':CHANGE(paths, DIR_SEP_CH, ' '):findArgs
    rc = GETENV('JBCRELEASEDIR', jbcrel)
    bins = ''
    pcnt = DCOUNT(paths, DIR_SEP_CH)
    FOR p = 1 TO pcnt
        path = FIELD(paths, DIR_SEP_CH, p)
        IF path EQ jbcrel:DIR_DELIM_CH:'bin' THEN CONTINUE
        EXECUTE ksh:find:' ':path:findArgs CAPTURING progs
        progs = CHANGE(progs, FILE_SUFFIX_SO, '')
        pgcnt = DCOUNT(progs, @AM)
        FOR pg = 1 TO pgcnt
            prog = progs<pg>
            prog = fnLAST(prog, DIR_DELIM_CH)
            LOCATE prog IN bins BY 'AL' SETTING bpos ELSE
                INS prog BEFORE bins<bpos>
            END
        NEXT pg
    NEXT p
!
! Find SUBROUTINES by going through the lib.el files
!
    subs = ''
    IF local THEN
        objectpaths = pwd:DIR_DELIM_CH:'lib'
    END ELSE
        rc = GETENV('JBCOBJECTLIST', objectpaths)
    END
    pcnt = DCOUNT(objectpaths, DIR_SEP_CH)
    FOR p = 1 TO pcnt
        path = FIELD(objectpaths, DIR_SEP_CH, p)
        IF path EQ jbcrel:DIR_DELIM_CH:'lib' THEN CONTINUE
        IF NOT(fnOPEN(path, F.path, error)) THEN
            CRT error:
            error = ''
            CONTINUE
        END
        K.cats = libdef:FILE_SUFFIX_EL
        READV catalogs FROM F.path, K.cats, 1 ELSE
            CRT 'Cannot read ':K.cats:' from ':path
            CONTINUE
        END
        loc = 0
        LOOP
            REMOVE subr FROM catalogs AT loc SETTING delim
            subr = fnDECODE(subr)
            LOCATE subr IN subs BY 'AL' SETTING spos ELSE
                INS subr BEFORE subs<spos>
            END
        WHILE delim DO REPEAT
    NEXT p
!
    bins<-1> = subs
    bc = DCOUNT(bins, @AM)
    CRT 'Processing ':bc:' binaries':
    tenth = INT(bc/10+.5)
    found = 0
    errors = ''
    FOR b = 1 TO bc
        prog = bins<b>
        IF LEN(prog) EQ 0 THEN CONTINUE
        GOSUB addcat
        IF NOT(MOD(b, tenth)) THEN CRT '.':
    NEXT b
    CRT
!
!    findFiles = 'find ':path:' -type f -exec grep -Iq . {} \;'
!    findFiles:= ' -and -exec fgrep -l jFormatCode {} \;'
!    findFiles:= '2>/dev/null|grep -v svn'
!
    CRT 'Found ':found:' catalogs'
    IF LEN(errors) THEN
        errcnt = DCOUNT(errors, @AM)
        CRT 'The following binaries could not be determined'
        CRT
        FOR e = 1 TO errcnt
            CRT errors<e>
        NEXT e
    END
    IF badcount THEN
        CRT 'BADCATS populated with ':badcount:' item':
        IF badcount GT 1 THEN CRT 's' ELSE CRT
    END
    STOP
addcat:
    EXECUTE ksh:'jshow -c ':prog CAPTURING io
    IF LEN(io) EQ 0 THEN
        errors<-1> = prog
        RETURN
    END
    IF NOT(INDEX(io, 'source file', 1)) THEN
        WRITEV '' ON F.badcatalog, prog, 1
        badcount++
        RETURN
    END
    found++
    iocnt = DCOUNT(io, @AM)
    MAT A.cat = ''
    FOR iol = 1 TO iocnt
        ioline = TRIM(io<iol>)
        BEGIN CASE
            CASE A.fpath EQ '' AND INDEX(ioline, 'Executable', 1) OR INDEX(ioline, 'Subroutine', 1)
                path = fnLAST(ioline,' ')
                A.fpath = fnTRIMLAST(path, DIR_DELIM_CH)
            CASE A.timestamp EQ '' AND INDEX(ioline, 'ersion', 1)
                rc = INDEX(ioline, 'ersion', 1)
                A.timestamp = FIELD(ioline[rc, 999], ' ', 2, 99)
            CASE A.fname EQ '' AND INDEX(ioline, 'source file', 1)
                A.fname = fnLAST(ioline, ' ')
                OPEN A.fname TO f.file THEN
                    rc = IOCTL(f.file, JBC_COMMAND_GETFILENAME, A.fname)
                    A.fname = CHANGE(A.fname, DIR_DELIM_CH:'.', '')
                END
        END CASE
        complete = @TRUE
        FOR a = 1 TO 3
            IF LEN(A.cat(a)) EQ 0 THEN
                complete = @FALSE
                BREAK
            END
        NEXT a
        IF complete THEN BREAK
    NEXT iol
    MATWRITE A.cat ON F.catalog, prog ON ERROR
        CRT 'Error writing ':prog
    END
    RETURN
