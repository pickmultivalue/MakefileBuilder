! PROGRAM ZUMBLDMAKE
!
! Generate a Makefile for discovered code
! by searching the current bin/lib for source
! then scans the source to build dependencies
!
    $option jabba
    INCLUDE JBC.h
    EQU ctrlA TO CHAR(1), ctrlB TO CHAR(2), ctrlC TO CHAR(3)
    EQU tab TO CHAR(9)
    DEFFUN fnOPEN()
    DEFFUN fnGETYN()
    DEFFUN fnLAST()
    DEFFUN fnPARSESOURCE()
    DEFFUN fnCONVBP2DIR()
    DEFFUN fnMOVEOBJECT()
!
    DEFFUN fnTRIMLAST()
    DEFFUN fnSPLITSENT()
    DIM A.cat(3)
    EQU A.fname  TO A.cat(1)
    EQU A.fpath TO A.cat(2)
    EQU A.timestamp TO A.cat(3)
!
    EQU word_lim TO 20
    DIM fvars(1000)
    fnames = ''
    relnames = ''
!
! Check this routine's dependencies
!
    dependencies = 'ZUMGETCATS':@AM:'fnOPEN':@AM:'fnGETYN':@AM:'fnLAST':@AM:'fnPARSESOURCE':@AM:'fnCONVBP2DIR':@AM:'fnMOVEOBJECT':@AM:'fnSPLITSENT'
    dc = DCOUNT(dependencies, @AM)
    missing = ''
    FOR i = 1 TO dc
        depnd = dependencies<i>
        EXECUTE 'jshow -c ':depnd CAPTURING io
        IF LEN(io) EQ 0 THEN
            missing<-1> = depnd
        END
    NEXT i
    IF LEN(missing) THEN
        CRT 'This utility relies on the following missing dependencies:'
        CRT
        CRT CHANGE(missing, @AM, ', ')
        STOP
    END
!
    CALL JBASEParseCommandLine1(args, opts, sent)
!
    hlpcmds = '?hH'
    FOR h = 1 TO LEN(hlpcmds)
        LOCATE '-':hlpcmds[h,1] IN args SETTING help THEN BREAK ELSE help = @FALSE
    NEXT h
    IF help THEN
        CRT 'Syntax: ZUMBLDMAKE {-options}'
        CRT
        CRT 'Where options:'
        CRT
        CRT '-[?,h,H] help/syntax'
        CRT '-v Verbose'
        CRT '-f<makefilename> (default: Makefile)'
        CRT '-o Overwrite'
        CRT '-m Ignore missing errors'
        CRT '-s Scan for catalog discovery'
        CRT '-C Convert BP files (convert to dir, create OBJECT directory if missing)'
!        CRT '-D Generate Doxygen Help'
        STOP
    END
!
    FINDSTR '-f' IN args SETTING fpos THEN
        k.make = args<fpos>[2, 999]
        DEL args<fpos>
    END ELSE k.make = 'Makefile'
!
    LOCATE '-o' IN args SETTING opos THEN
        overwrite = @TRUE
        DEL args<opos>
    END ELSE overwrite = @FALSE
!
    LOCATE '-m' IN args SETTING opos THEN
        ignoreMissing = @TRUE
        DEL args<opos>
    END ELSE ignoreMissing = @FALSE
!
    LOCATE '-s' IN args SETTING opos THEN
        scanForCatalogs = @TRUE
        DEL args<opos>
    END ELSE scanForCatalogs = @FALSE
!
    LOCATE '-v' IN args SETTING vpos THEN
        verbose = @TRUE
        DEL args<vpos>
    END ELSE verbose = @FALSE
!
    LOCATE '-C' IN args SETTING opos THEN
        convertFiles = @TRUE
        DEL args<opos>
    END ELSE convertFiles = @FALSE
!
    LOCATE '-D' IN args SETTING opos THEN
        doxyGen = @TRUE
        DEL args<opos>
    END ELSE doxyGen = @FALSE
!
    IF LEN(args) THEN
        CRT 'Invalid args: ':CHANGE(args, @AM, ', ')
        STOP
    END
!
    rc = GETENV('PWD',pwd)
    missing_files = ''
    ZUMCATS = '.':DIR_DELIM_CH:'ZUMCATS'
    ZUMLIBS = '.':DIR_DELIM_CH:'ZUMLIBS'
    BADCATS = '.':DIR_DELIM_CH:'BADCATS'
    BASICFAILS = '.':DIR_DELIM_CH:'BASICFAILS'
    IF NOT(fnOPEN('.', F.currdir, error)) THEN missing_files<-1> = error
    IF NOT(fnOPEN(ZUMCATS, F.zumcats, error)) THEN
        IF NOT(scanForCatalogs) THEN
            CRT '-s option specified but ZUMCATS could not be opened'
            STOP
        END
        question = 'Create ZUMCATS file for building catalog list'
        IF fnGETYN(question, 'Y':@VM:'N') EQ 'Y' THEN
            error = ''
            EXECUTE 'CREATE-FILE DATA ':ZUMCATS:' 47'
            EXECUTE 'CREATE-FILE DATA ':ZUMLIBS:' 47'
            EXECUTE 'CREATE-FILE DATA ':BADCATS:' 47'
            EXECUTE 'CREATE-FILE DATA ':BASICFAILS:' 47'
            rc = fnOPEN(ZUMCATS, F.zumcats, error)
        END
        missing_files<-1> = error
    END
    rc = fnOPEN(ZUMLIBS, F.zumlibs, error)
    GOSUB checkMissing
!
    READ makefile FROM F.currdir, k.make THEN
        IF overwrite THEN
            ans = 'Y'
            IF verbose THEN
                CRT 'Overwriting existing ':k.make
            END
        END ELSE
            ans = fnGETYN(k.make:' exists - overwrite', 'Y':@VM:'N':@AM:'N')
        END
        IF ans EQ 'N' THEN STOP
    END
!
! Do bin/lib discovery
!
    IF scanForCatalogs THEN
        binpath = pwd:DIR_DELIM_CH:'bin'
        sys = new object("$system")
        bc = sys->getbinaries('ZUMGETCATS', 23)
        result = sys->binaries[1]
        binpath := DIR_SEP_CH:fnTRIMLAST(result->fullpath, DIR_DELIM_CH)
        binpath := DIR_SEP_CH:SYSTEM(1011):DIR_DELIM_CH:'bin'
        rc = PUTENV('PATH=':binpath)
        EXECUTE @IM:'kZUMGETCATS'
    END
!
    pwd = CHANGE(pwd, DIR_DELIM_CH, @AM)
    pwd_count = DCOUNT(pwd, @AM)
    binvars = ''
    libvars = ''
    includes = ''
    missing_mobject = ''
    F.temp = F.zumcats
    GOSUB checkObject
    F.temp = F.zumlibs
    GOSUB checkObject
    IF LEN(missing_mobject) THEN
        CRT 'The following files are not compatible.'
        CRT 'Please create a ,OBJECT data level for:'
        CRT CHANGE(missing_mobject, @AM, @CR:@LF)
        STOP
    END
!
    GOSUB checkMissing
!
    fc = DCOUNT(fnames<1>, @VM)
    IF NOT(fc) THEN
        CRT 'No files discovered to build. Stopping.'
        STOP
    END
!
    IF NOT(GETCWD(curr_dir)) THEN curr_dir = '.'
    curr_dir := DIR_DELIM_CH
!
    missing_code = ''
    binTargets = ''
    libTargets = ''
    subroutines = ''
    executes = ''
    FOR f = 1 TO fc
        fname = fnames<1, f>
        LOCATE fname IN relnames<1> SETTING rpos THEN
            fname = relnames<2,rpos>
        END
        progs = fnames<2, f>
        pc = DCOUNT(progs, @SVM)
        FOR p = 1 TO pc
            prog = progs<1, 1, p>
            LOCATE prog IN libvars BY 'AL' SETTING subrpos THEN
                libTargets<1,-1> = prog
                fnames<4, f, p> = @TRUE
            END ELSE
                binTargets<1, -1> = prog
                subrpos = @FALSE
            END
            includes = ''
            GOSUB processSource
            IF NOT(rc) THEN CONTINUE
            IF subrpos THEN
                libTargets<2,-1> = prog
            END ELSE
                binTargets<2, -1> = prog
            END
            fnames<5, f, p> = prog
            fnames<3, f, p> = CONVERT(includes, @AM:@VM:@SVM, ctrlA:ctrlB:ctrlC)
        NEXT p
    NEXT f
    IF LEN(missing_code) THEN
        CRT 'The following problems were encountered:'
        CRT
        CRT CHANGE(CHANGE(missing_code, @AM, @CR:@LF), @VM, @CR:@LF)
        IF NOT(ignoreMissing) THEN STOP
    END
    IF LEN(subroutines) THEN
        subroutines = CONVERT(subroutines, @VM, @AM)
        WRITE subroutines ON F.currdir, 'subroutines_found'
        CRT 'subroutines_found written to current directory'
    END
    IF LEN(executes) THEN
        executes = CONVERT(executes, @VM, @AM)
        WRITE executes ON F.currdir, 'executes_found'
        CRT 'executes_found written to current directory'
    END
!
! Initialise non-Windows strings
!
    K.Makefile = 'Makefile'
    dir_delim = '/'
    cmd_suffix = ''
    obj_suffix = '.o'
    lib_target = 'lib.el'
    remove_cmd = 'rm'
    foundDollar = @FALSE
!
    clean = 'libobjs':@AM:'binobjs'
    FOR m = 1 TO 2
        libc = 1
        binc = 1
        phony = ''
        makeinit = ''
        makelabels = ''
        makemakes = ''
        makewrapup = ''
        targets = ''
        libs = ''
        bins= ''
        catsubs = ''
        rebuild = ''
        object_files = ''
        IF m EQ 1 THEN
            makeinit<-1> = @AM:'define catlib'
            makeinit<-1> = 'echo "" $(foreach fname,$(?),&& CATALOG -L./lib $(firstword $(subst /, ,$(fname))) $(word 2,$(subst /, ,$(fname))))'
            makeinit<-1> = 'endef'
        END
        phony<-1> = 'all'
        FOR f = 1 TO fc
            fname = fnames<1, f>
            progs = fnames<2, f>
            xrefs = fnames<3, f>
            flags = fnames<4, f>
            names = fnames<5, f>
            IF fname[1, LEN(curr_dir)] EQ curr_dir THEN
                fname = fname[LEN(curr_dir)+1, 999]
            END
            subs = ''
            exes = ''
            objfile = fname:']MOBJECT'
            OPEN objfile TO f.object THEN
                objfile:= dir_delim
                object_files<-1> = objfile
            END ELSE
                objfile = ''
                CRT 'WARNING: ':objfile:' not available. Makefile will be incomplete'
            END
            libtarget = 'lib':dir_delim:lib_target
            pc = DCOUNT(progs, @SVM)
            FOR p = 1 TO pc
                target = progs<1, 1, p>
                xref = xrefs<1, 1, p>
                flag = flags<1, 1, p>
                source = names<1, 1, p>
                xref = CONVERT(xref, ctrlA:ctrlB:ctrlC, @AM:@VM:@SVM)
                dependency = fname:dir_delim:source
                loc = 0
                LOOP
                    REMOVE incl FROM xref AT loc SETTING delim
                    IF LEN(incl) THEN
                        dependency := ' ':CHANGE(incl, '$', '$$')
                    END
                WHILE delim DO REPEAT
                IF target EQ source THEN
                    object = '$$':target
                    foundDollar = @TRUE
                END ELSE
                    object = target:obj_suffix
                END
                IF LEN(objfile) THEN
                    object = objfile:object
                    makemakes<-1> = @AM:object:': ':dependency
                    makemakes<-1> = tab:'BASIC ':fname:' ':source
                    IF flag THEN
                        libs<-1> = object
                        subs<-1> = source
                    END ELSE
                        exes<-1> = source
                        bins<-1> = object
                        target = '.':dir_delim:'bin':dir_delim:target:cmd_suffix
                        targets<-1> = target
                        makemakes<-1> = @AM:target:': ':object
                        makemakes<-1> = tab:'CATALOG -o.':dir_delim:'bin ':fname:' ':source
                    END
                END
            NEXT p
            subs = TRIM(CHANGE(subs, @AM, ' '))
            IF m EQ 2 AND LEN(subs) THEN
                subs = fnSPLITSENT(subs, word_lim)
                subc = DCOUNT(subs, @AM)
                FOR sc = 1 TO subc
                    catsubs<-1> = tab:'CATALOG -L.':dir_delim:'lib ':fname:' ':subs<sc>
                    rebuild<-1> = tab:'CATALOG -L.':dir_delim:'lib ':fname:' ':subs<sc>
                NEXT sc
            END
            progs = fnSPLITSENT(exes, word_lim)
            progc = DCOUNT(progs, @AM)
            FOR pc = 1 TO progc
                rebuild<-1> = tab:'CATALOG -o.':dir_delim:'bin ':fname:' ':progs<pc>
            NEXT pc
        NEXT f
        libs = fnSPLITSENT(libs, word_lim)
        libc = DCOUNT(libs, @AM)
        libtarget := ':'
        libmake = tab:'make'
        FOR lc = 1 TO libc
            liblabel = 'libs':lc
            libdepend = '$(libobj':lc:')'
            makemakes<-1> = @AM:liblabel:': ':libdepend
            IF m EQ 1 THEN
                makemakes<-1> = tab:'$(catlib)'
            END
            libtarget := ' ':libdepend
            libmake := ' ':liblabel
        NEXT lc
        IF m EQ 2 THEN
            makemakes<-1> = catsubs
        END
        makemakes<-1> = @AM:libtarget:@AM:libmake
        libtarget = FIELD(libtarget, ':', 1)
        libs = fnSPLITSENT(libs, word_lim)
        lc = DCOUNT(libs, @AM)
        libobjs = 'libobjs=':
        FOR lib = lc TO 1 STEP -1
            libobjvar = 'libobj':lib
            makeinit<-1> = libobjvar:'=':libs<lib>
            libobjs := '$(':libobjvar:') '
        NEXT lib
        targets = fnSPLITSENT(targets, word_lim)
        makelabels<-1> = @AM:'targets: allbins alllibs'
        alllibs = 'alllibs: $(libobjs)'
        alllibs<-1> = tab:'make ':libtarget
        allbins = tab:'make'
        lc = DCOUNT(targets, @AM)
        FOR target = lc TO 1 STEP -1
            targetbinvar = 'bin':target
            makeinit<-1> = targetbinvar:'=':targets<target>
            allbins := ' $(':targetbinvar:')'
        NEXT lib
        phony<-1> = 'targets'
        makelabels<-1> = @AM:'allbins: $(binobjs)'
        makelabels<-1> = allbins
        bins = fnSPLITSENT(bins, word_lim)
        lc = DCOUNT(bins, @AM)
        binobjs = 'binobjs=':
        FOR bin = lc TO 1 STEP -1
            binobjvar = 'binobj':bin
            makeinit<-1> = binobjvar:'=':bins<bin>
            binobjs := '$(':binobjvar:') '
        NEXT lib
        INS TRIM(binobjs) BEFORE makeinit<-1>
        INS TRIM(libobjs) BEFORE makeinit<-1>
        makeinit<-1> = @AM:alllibs
        makewrapup<-1> = @AM:'rebuild: $(libobjs) $(binobjs)'
        makewrapup<-1> = rebuild
        makewrapup<-1> = @AM:'clean:'
        makewrapup<-1> = tab:'-':remove_cmd:' .':dir_delim:'lib':dir_delim:'lib*.*'
        nbr_obj_files = DCOUNT(object_files, @AM)
        FOR f = 1 TO nbr_obj_files
            opts = (IF m EQ 2 THEN ' /F' ELSE '')
            obj_dir = object_files<f>
            IF obj_dir[1,1] NE dir_delim THEN
                obj_dir = '.':dir_delim:obj_dir
            END
            makewrapup<-1> = tab:'-':remove_cmd:opts:' ':obj_dir:'*'
        NEXT f
        IF foundDollar THEN
            FOR c = 1 TO 2
                cvar = '$(':clean<c>:')'
                IF m = 1 THEN
                    cvar = '$(subst $$,\$$,':cvar:')'
                END
                makewrapup<-1> = tab:'-':remove_cmd:' ':cvar
            NEXT c
        END
        INS 'all: targets' BEFORE makeinit<1>
        INS '.PHONY : ':CHANGE(phony, @AM, ' '):@AM BEFORE makeinit<1>
        makefile = makeinit:@AM:makelabels:@AM:@AM:makemakes:@AM:@AM:makewrapup
        WRITE makefile ON F.currdir,K.Makefile
!
! Windows settings
!
        K.Makefile = 'Makefile.WIN32'
        dir_delim = '\'
        cmd_suffix = '.exe'
        obj_suffix = '.obj'
        lib_target = 'libdef.def'
        remove_cmd = 'del /Q'
    NEXT m
    makefile = 'nmake -f Makefile.WIN32 %1 %2 %3 %4 %5 %6 %7 %8 %9'
    WRITE makefile ON F.currdir,'make.bat'
    CRT 'Created make.bat and Makefile{.WIN32}'
!
    STOP
!
checkMissing:
!
    IF LEN(missing_files) THEN
        CRT 'Cannot open the following files: ':CHANGE(missing_files, @AM, ', ')
        STOP
    END
    RETURN
!
processSource:
!
    missing_inc = ''
    includes<3> = subroutines
    includes<4> = executes
    rc = fnPARSESOURCE(convertFiles, fname, fvars(rpos), prog, includes, missing_inc)
    subroutines = includes<3>
    executes = includes<4>
    DEL includes<3>
    DEL includes<3>
    IF rc THEN
        IF LEN(missing_inc) THEN
            missing_code<-1> = 'Code ':fname:',':prog
            IF LEN(missing_inc<1>) THEN
                missing_code<-1> = "Include files that couldn't be opened:":@AM:missing_inc<1>
            END
            IF LEN(missing_inc<2>) THEN
                missing_code<-1> = "Includes that couldn't be read:":@AM:missing_inc<2>
            END
        END
    END

    RETURN

checkObject: !
    SELECT F.temp
    LOOP WHILE READNEXT prog DO
        MATREAD A.cat FROM F.temp, prog ELSE STOP 202, prog
        LOCATE A.fname IN missing_files SETTING mpos THEN CONTINUE
        LOCATE A.fname IN missing_mobject SETTING mpos THEN CONTINUE
        error = @FALSE
        LOCATE A.fname IN fnames<1> BY 'AL' SETTING fpos ELSE
            INS A.fname BEFORE fnames<1, fpos>
            INS '' BEFORE fnames<2, fpos>
            LOCATE A.fname IN relnames<1> SETTING rpos ELSE
                INS A.fname BEFORE relnames<1,rpos>
                INS '' BEFORE relnames<2,rpos>
            END
            IF NOT(fnOPEN(A.fname, f.var, '':@AM:@TRUE)) THEN
                missing_files<-1> = A.fname
                error = @TRUE
            END ELSE
                objFile = A.fname:']MOBJECT'
                IF NOT(fnOPEN(objFile, f.object, '')) THEN
                    IF convertFiles THEN
                        EXECUTE 'CREATE-FILE DATA ':objFile:' TYPE=UD'
                        error = NOT(fnOPEN(objFile, f.object, ''))
                        IF NOT(error) THEN
                            IF NOT(fnMOVEOBJECT(f.var, f.object)) THEN
                                CRT 'Error moving object code for ':A.fname
                                CRT 'Aborting.'
                                STOP
                            END
                        END
                    END ELSE error = @TRUE
                END
                IF error THEN
                    missing_mobject<-1> = A.fname
                END ELSE
                    fstatus = ''
                    rc = IOCTL(f.var, JIOCTL_COMMAND_FILESTATUS, fstatus)
                    IF fstatus<1> NE 'UD' THEN
                        IF convertFiles THEN
                            CLOSE f.var
                            IF NOT(fnCONVBP2DIR(A.fname, f.var)) THEN
                                CRT 'Fatal error opening/converting ':A.fname
                                STOP
                            END
                        END ELSE error = @TRUE
                    END
                    IF error THEN
                        CRT A.fname:' is not a directory'
                        missing_files<-1> = A.fname
                    END ELSE
                        fvars(rpos) = f.var
                        relnames<2,rpos> = A.fname
                    END
                END
            END
        END
        IF error THEN CONTINUE
        LOCATE prog IN fnames<2, fpos> BY 'AL' SETTING ppos ELSE
            INS prog BEFORE fnames<2, fpos, ppos>
        END
        IF fnLAST(A.fpath, DIR_DELIM_CH) EQ 'bin' THEN
            LOCATE A.fpath IN binvars BY 'AL' SETTING pos ELSE
                INS A.fpath BEFORE binvars<pos>
            END
        END ELSE
            LOCATE prog IN libvars BY 'AL' SETTING pos ELSE
                INS prog BEFORE libvars<pos>
            END
        END
    REPEAT
    RETURN
