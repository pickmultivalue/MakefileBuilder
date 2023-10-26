! PROGRAM JUTIL_GETCATS
!

    $option jabba

    INCLUDE JBC.h
!
    CALL JBASEParseCommandLine1(args, opts, sent)
!
    LOCATE '-l' IN args SETTING local ELSE local = @FALSE
    LOCATE '-v' IN args SETTING verbose ELSE verbose = @FALSE
    LOCATE '-j' IN args SETTING usejelf ELSE usejelf = @FALSE
    LOCATE '-L' IN args SETTING Lopt THEN
        processbins = @FALSE
    END ELSE
        processbins = @TRUE
    END
    LOCATE '-B' IN args SETTING Lopt THEN
        processlibs = @FALSE
    END ELSE
        processlibs = @TRUE
    END
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
    rc = GETENV('PWD',pwd)
    rc = GETENV('JUTLMAKEBINS',devbins)
    rc = GETENV('JUTLMAKELIBS',devlibs)
    IF LEN(devbins) EQ 0 OR LEN(devlibs) EQ 0 THEN
        CRT 'Please set JUTLMAKEBINS and JUTLMAKELIBS to the target bins/libs'
        STOP
    END
    debug_prog = ''
    rc = GETENV('JUTILDEBUGPROG',debug_prog)
    tmpfix = ''
    rc = GETENV('JUTILTMPFIX',tmpfix)
    dc = DCOUNT(devbins, DIR_SEP_CH)
    fdevbins = ''
    FOR f = 1 TO dc
        devbin = FIELD(devbins, DIR_SEP_CH, f)
        rc = fnOPEN(devbin, f.devbin, 1:@AM:@TRUE)
        LOCATE devbin IN fdevbins SETTING pos ELSE fdevbins<-1> = devbin
    NEXT f
    dc = DCOUNT(devlibs, DIR_SEP_CH)
    fdevlibs = ''
    FOR f = 1 TO dc
        devlib = FIELD(devlibs, DIR_SEP_CH, f)
        rc = fnOPEN(devlib, f.devlib, 1:@AM:@TRUE)
        LOCATE devlib IN fdevlibs SETTING pos ELSE fdevlibs<-1> = devlib
    NEXT f
    rc = fnOPEN('.', F.currdir, 1)
    READ binpaths FROM F.currdir, 'JUTLBINPATHS' ELSE
        binpaths = CHANGE(devbins, DIR_SEP_CH, @AM);!pwd:DIR_DELIM_CH:'bin'
    END
    READ libpaths FROM F.currdir, 'JUTLOBJPATHS' ELSE
        libpaths = CHANGE(devlibs, DIR_SEP_CH, @AM);!pwd:DIR_DELIM_CH:'lib'
    END
    rc = fnOPEN('.':DIR_DELIM_CH:'JUTLCATS', F.catalog, 1)
    rc = fnOPEN('.':DIR_DELIM_CH:'JUTLLIBS', F.library, 1)
    rc = fnOPEN('.':DIR_DELIM_CH:'BADCATS', F.badcatalog, 1)
    CLEARFILE F.badcatalog
    badcount = 0
    openedFiles = ''
    fullpaths = ''
!
    IF processbins THEN
        CLEARFILE F.badcatalog
        CRT 'Building binary list (filtering using ':devbins:')...':CHAR(0):
        sys = new object("$system")
        rc = PUTENV('PATH=':devbins)
        bc = sys->getbinaries('', 23)
        CRT sys->binaries->$size():' discovered'
        found = 0
        errors = ''
        paths = ''
        FOR path IN binpaths
            opt = 1:@AM:@true
            IF fnOPEN(path, f.path, opt) THEN
                LOCATE path IN paths BY 'AL' SETTING pos ELSE
                    INS path BEFORE paths<pos>
                END
            END
        NEXT path
        IF INDEX(SYSTEM(1017), 'WIN', 1) THEN paths = UPCASE(paths)
        idx_offset = (IF sys->binpath[0]->index EQ 1 THEN 1 ELSE 0)
        fdevs = fdevbins
        FOR result IN sys->binaries
            IF result->$hasproperty('source') THEN
                IF NOT(INDEX(result->source, "source file unknown",1)) THEN
                    prog = result->name
                    IF prog EQ debug_prog THEN DEBUG
                    A.fpath = sys->binpath[result->index-idx_offset]->directory
                    IF verbose THEN CRT prog:
                    GOSUB addprog
                    IF verbose THEN CRT
                END
            END
        NEXT result
        CRT
        CRT 'Found ':found:' programs'
        CRT
    END
    IF processlibs THEN
        CRT 'Building library list (filtering using ':devlibs:')...':CHAR(0):
        sys = new object("$system")
        rc = PUTENV('JBCOBJECTLIST=':devlibs)
        sysm = sys->getroutines('',23)
        CRT sys->routine->$size():' discovered'
        found = 0
        errors = ''
        paths = ''
        F.catalog = F.library ;! lazy F.target switch
        FOR path IN libpaths
            LOCATE path IN paths BY 'AL' SETTING pos ELSE
                INS path BEFORE paths<pos>
            END
        NEXT path
        IF INDEX(SYSTEM(1017), 'WIN', 1) THEN paths = UPCASE(paths)
        fdevs = fdevlibs
        FOR result in sys->routine
            IF result->$hasproperty('source') THEN
                IF NOT(INDEX(result->source, "source file unknown",1)) THEN
                    prog = FIELD(result->version, ' ', 2)
                    has_jelf = (usejelf AND result->$hasproperty('jelf'))
                    IF has_jelf THEN
                        rc = sys->getroutines(prog, 1)
                        idx = sys->object->$size()-1
                        result->fullpath = sys->object[idx]->fullpath
                        IF result->fullpath EQ 'main()' THEN prog = ''
                    END ELSE
                        idx = result->object_index
                    END
                    IF LEN(prog) THEN
                        IF prog EQ debug_prog THEN DEBUG
                        result->fullpath = sys->object[idx]->fullpath
                        A.fpath = result->fullpath
                        A.fpath = fnTRIMLAST(A.fpath, DIR_DELIM_CH)
                        IF verbose THEN CRT prog:
                        GOSUB addprog
                        IF verbose THEN CRT
                    END
                END
            END
        NEXT result
        CRT
!
        CRT 'Found ':found:' subroutines'
    END
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
    F.target = F.catalog
    READV apath FROM F.catalog, prog, 2 THEN
        IF apath NE A.fpath THEN
            F.target = F.badcatalog
            badcount++
        END
    END
    apath = A.fpath
    fpath = 1:@AM:@TRUE
    rc = fnOPEN(apath, f.path, fpath)
#if WIN32
    apath = UPCASE(apath)
#endif
    LOCATE apath IN paths BY 'AL' SETTING ok ELSE RETURN

    found++
    A.fname = fnLAST(io, ' ')
    IF A.fname EQ '/tmp' AND tmpfix NE '' THEN
        EXECUTE tmpfix:' ':prog CAPTURING A.fname
    END ELSE
        RETURN
    END
    LOCATE A.fname IN openedFiles<1> BY 'AL' SETTING fpos THEN
        A.fname = openedFiles<2,fpos>
    END ELSE
        INS A.fname BEFORE openedFiles<1,fpos>
        OPEN A.fname TO f.file THEN
            rc = IOCTL(f.file, JBC_COMMAND_GETFILENAME, A.fname)
            A.fname = CHANGE(A.fname, DIR_DELIM_CH:'.', '')
        END ELSE A.fname = ''
        INS A.fname BEFORE openedFiles<2,fpos>
        IF (A.fname 'R#2') EQ ']D' THEN
            errors<-1> = A.fname:' derived in error'
            RETURN
        END
    END
    A.timestamp = FIELD(result->version, ' ', 6, 99)
    MATWRITE A.cat ON F.target, prog ON ERROR
        CRT 'Error writing ':prog
        STOP
    END
    RETURN
addprog: !
    fullpath = result->fullpath
    fullpath = fnTRIMLAST(fullpath, DIR_DELIM_CH)
    LOCATE fullpath IN fullpaths<1> BY 'AL' SETTING pos THEN
        fpath = fullpaths<2,pos>
    END ELSE
        fpath = 1:@AM:@TRUE
        INS fullpath BEFORE fullpaths<1,pos>
        IF fnOPEN(fullpath, f.path, fpath) THEN
            fpath = fullpath
            INS fpath BEFORE fullpaths<2,pos>
        END
    END
    LOCATE fpath IN fdevs SETTING pos THEN
        GOSUB addcat
    END
    RETURN
