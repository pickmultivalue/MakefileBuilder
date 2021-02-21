! PROGRAM ZUMGETCATS
!

$option jabba

    INCLUDE JBC.h
!
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
    rc = fnOPEN('.', F.currdir, 1)
    READ binpaths FROM F.currdir, 'ZUMBINPATHS' ELSE STOP 202, '. ZUMBINPATHS'
    READ libpaths FROM F.currdir, 'ZUMOBJPATHS' ELSE STOP 202, '. ZUMOBJPATHS' 
    rc = fnOPEN('.':DIR_DELIM_CH:'ZUMCATS', F.catalog, 1)
    rc = fnOPEN('.':DIR_DELIM_CH:'BADCATS', F.badcatalog, 1)
    CLEARFILE F.catalog
    CLEARFILE F.badcatalog
    badcount = 0
    openedFiles = '' 
!    sys = new object("$system")
!        
    ksh = @IM:'k'
!
! Look through PATH to find .so files
! (which would be the shared object version of a cataloged program)
!
!    win = INDEX(SYSTEM(1017), 'WIN', 1)
!    IF win THEN
!        libdef = 'libdef'
!        findcmd = 'jfind'
!        devnull = 'NUL'
!    END ELSE
!        libdef = 'lib' 
!        findcmd = 'find' 
!        devnull = '/dev/null' 
!    END
!    IF local THEN
!        rc = GETCWD(pwd)
!        paths = pwd:DIR_DELIM_CH:'bin'
!    END ELSE
!        rc = GETENV('PATH', paths)
!    END
!    findArgs = ' -name *':FILE_SUFFIX_SO:' -print 2>':devnull
!    findBins = findcmd:' ':CHANGE(paths, DIR_SEP_CH, ' '):findArgs
!    rc = GETENV('JBCRELEASEDIR', jbcrel)
!    bins = ''
!    pcnt = DCOUNT(paths, DIR_SEP_CH)
!    FOR p = 1 TO pcnt
!        path = FIELD(paths, DIR_SEP_CH, p)
!        IF path EQ jbcrel:DIR_DELIM_CH:'bin' THEN CONTINUE
!        EXECUTE ksh:findcmd:' ':path:findArgs CAPTURING progs
!        CONVERT @CR TO '' IN progs
!        progs = CHANGE(progs, FILE_SUFFIX_SO, '')
!        pgcnt = DCOUNT(progs, @AM)
!        FOR pg = 1 TO pgcnt
!            prog = progs<pg>
!            prog = fnLAST(prog, DIR_DELIM_CH)
!            IF prog MATCHES "0X'_TMP_'1N0N" THEN CONTINUE
!            IF prog MATCHES "0X'.exe'" THEN CONTINUE
!            LOCATE prog IN bins BY 'AL' SETTING bpos ELSE
!                INS prog BEFORE bins<bpos>
!            END
!        NEXT pg
!    NEXT p
!!
!! Find SUBROUTINES by going through the lib.el files
!!
!    subs = ''
!    IF local THEN
!        objectpaths = pwd:DIR_DELIM_CH:'lib'
!    END ELSE
!        rc = GETENV('JBCOBJECTLIST', objectpaths)
!    END
!    pcnt = DCOUNT(objectpaths, DIR_SEP_CH)
!    FOR p = 1 TO pcnt
!        path = FIELD(objectpaths, DIR_SEP_CH, p)
!        IF path EQ jbcrel:DIR_DELIM_CH:'lib' THEN CONTINUE
!        IF NOT(fnOPEN(path, F.path, error)) THEN
!            CRT error:
!            error = ''
!            CONTINUE
!        END
!        K.cats = libdef:FILE_SUFFIX_EL
!        READV catalogs FROM F.path, K.cats, 1 ELSE
!            CRT 'Cannot read ':K.cats:' from ':path
!            CONTINUE
!        END
!        loc = 0
!        LOOP
!            REMOVE subr_id FROM catalogs AT loc SETTING delim
!            subr_id = fnDECODE(subr_id)
!            LOCATE subr_id IN subs BY 'AL' SETTING spos ELSE
!                INS subr_id BEFORE subs<spos>
!            END
!        WHILE delim DO REPEAT
!    NEXT p
!
    CRT 'Building binary list...'
    sys = new object("$system")
    bc = sys->getbinaries('', 23)
    bc = sys->binaries->$size() - 1
    CRT 'Processing ':bc:' binaries':
    found = 0
    errors = ''
    paths = ''
    FOR path IN binpaths
        LOCATE path IN paths BY 'AL' SETTING pos ELSE
            INS path BEFORE paths<pos>
        END
    NEXT path
    FOR result IN sys->binaries
        IF result->$hasproperty('source') THEN
            prog = result->name
            IF LEN(prog) THEN
                A.fpath = sys->binpath[result->index]->directory
                GOSUB addcat
            END
        END
    NEXT result 
    CRT
    CRT 'Found ':found:' programs'

    CRT 'Building library list...'
    sys = new object("$system")
    sysm = sys->getroutines('',23)
    bc = sys->routine->$size() - 1
    CRT 'Processing ':bc:' libraries':
    found = 0
    errors = ''
    paths = ''
    FOR path IN libpaths
        LOCATE path IN paths BY 'AL' SETTING pos ELSE
            INS path BEFORE paths<pos>
        END
    NEXT path
    FOR result in sys->routine
        IF result->$hasproperty('source') THEN
            prog = FIELD(result->version, ' ', 2)
            IF LEN(prog) THEN
                A.fpath = sys->object[result->object_index]->fullpath
                A.fpath = fnTRIMLAST(A.fpath, DIR_DELIM_CH)
                GOSUB addcat
            END
        END
    NEXT result 
    CRT
!
!    findFiles = 'find ':path:' -type f -exec grep -Iq . {} \;'
!    findFiles:= ' -and -exec fgrep -l jFormatCode {} \;'
!    findFiles:= '2>/dev/null|grep -v svn'
!
    CRT 'Found ':found:' subroutines'
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
    
    LOCATE A.fpath IN paths BY 'AL' SETTING ok ELSE RETURN

    rc = IOCTL(F.catalog, JIOCTL_COMMAND_FINDRECORD, prog)
    IF rc THEN RETURN 
    
    io = result->source
    IF NOT(INDEX(io, 'source file', 1)) THEN
        WRITEV '' ON F.badcatalog, prog, 1
        badcount++
        RETURN
    END
    IF LEN(io) EQ 0 THEN
        errors<-1> = prog
        RETURN
    END
    found++
    A.fname = fnLAST(io, ' ')
    LOCATE A.fname IN openedFiles<1> BY 'AL' SETTING fpos THEN
        A.fname = openedFiles<2,fpos> 
    END ELSE
        INS A.fname BEFORE openedFiles<1,fpos>
        OPEN A.fname TO f.file THEN
            rc = IOCTL(f.file, JBC_COMMAND_GETFILENAME, A.fname)
            A.fname = CHANGE(A.fname, DIR_DELIM_CH:'.', '')
        END ELSE A.fname = '' 
        INS A.fname BEFORE openedFiles<2,fpos>
    END
    A.timestamp = FIELD(result->version, ' ', 6, 99)
    MATWRITE A.cat ON F.catalog, prog ON ERROR
        CRT 'Error writing ':prog
    END
    RETURN
