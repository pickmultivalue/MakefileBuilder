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
    rc = GETENV('PWD',pwd)
    rc = fnOPEN('.', F.currdir, 1)
    READ binpaths FROM F.currdir, 'ZUMBINPATHS' ELSE 
        binpaths = pwd:DIR_DELIM_CH:'bin'
    END
    READ libpaths FROM F.currdir, 'ZUMOBJPATHS' ELSE
        libpaths = pwd:DIR_DELIM_CH:'lib'
    END
    rc = fnOPEN('.':DIR_DELIM_CH:'ZUMCATS', F.catalog, 1)
    rc = fnOPEN('.':DIR_DELIM_CH:'BADCATS', F.badcatalog, 1)
    CLEARFILE F.catalog
    CLEARFILE F.badcatalog
    badcount = 0
    openedFiles = '' 
!
    CRT 'Building binary list...':CHAR(0):
    sys = new object("$system")
    bc = sys->getbinaries('', 23)
    CRT sys->binaries->$size():' discovered'
    found = 0
    errors = ''
    paths = ''
    FOR path IN binpaths
        LOCATE path IN paths BY 'AL' SETTING pos ELSE
            INS path BEFORE paths<pos>
        END
    NEXT path
    idx_offset = (IF sys->binpath[0]->index EQ 1 THEN 1 ELSE 0)
    FOR result IN sys->binaries
        IF result->$hasproperty('source') THEN
            prog = result->name
            IF LEN(prog) THEN
                A.fpath = sys->binpath[result->index-idx_offset]->directory
                GOSUB addcat
            END
        END
    NEXT result
    CRT
    CRT 'Found ':found:' programs'
    CRT 
    CRT 'Building library list...':CHAR(0):
    sys = new object("$system")
    sysm = sys->getroutines('',23)
    CRT sys->routine->$size():' discovered'
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
