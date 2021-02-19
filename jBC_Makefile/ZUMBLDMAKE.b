! PROGRAM ZUMBLDMAKE
!
! Generate a Makefile for discovered code
! by searching the current bin/lib for source
! then scans the source to build dependencies
!
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
    DIM A.cat(3)
    EQU A.fname  TO A.cat(1)
    EQU A.fpath TO A.cat(2)
    EQU A.timestamp TO A.cat(3)
!
    DIM fvars(1000)
    fnames = ''
    relnames = ''
!
! Check this routine's dependencies
!
    dependencies = 'ZUMGETCATS':@AM:'fnOPEN':@AM:'fnGETYN'
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
        CRT '-s Skip catalog discovery'
        CRT '-C Convert BP files (convert to dir, create OBJECT directory if missing)'
        CRT '-D Generate Doxygen Help'
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
        skipZUMCATS = @TRUE
        DEL args<opos>
    END ELSE skipZUMCATS = @FALSE
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
    missing_files = ''
    IF NOT(fnOPEN('.', F.currdir, error)) THEN missing_files<-1> = error
    IF NOT(fnOPEN('ZUMCATS', F.zumcats, error)) THEN
        IF skipZUMCATS THEN
            CRT '-s option specified but ZUMCATS could not be opened'
            STOP
        END 
        question = 'Create ZUMCATS file for building catalog list'
        IF fnGETYN(question, 'Y':@VM:'N') EQ 'Y' THEN
            error = ''
            EXECUTE 'CREATE-FILE DATA ZUMCATS 47'
            EXECUTE 'CREATE-FILE DATA BADCATS 47'
            rc = fnOPEN('ZUMCATS', F.zumcats, error)
        END
        missing_files<-1> = error
    END
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
    IF NOT(skipZUMCATS) THEN EXECUTE 'ZUMGETCATS -l'
!
    rc = GETENV('PWD',pwd)
    pwd = CHANGE(pwd, DIR_DELIM_CH, @AM)
    pwd_count = DCOUNT(pwd, @AM)
    binvars = ''
    libvars = ''
    includes = ''
    SELECT F.zumcats
    missing_mobject = ''
    LOOP WHILE READNEXT prog DO
        MATREAD A.cat FROM F.zumcats, prog ELSE STOP 202, prog
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
                objFile = A.fname:',OBJECT'
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
                    status = ''
                    rc = IOCTL(f.var, JIOCTL_COMMAND_FILESTATUS, status)
                    IF status<1> NE 'UD' THEN
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
    FOR f = 1 TO fc
        fname = fnames<1, f>
        LOCATE fname IN relnames<1> SETTING rpos THEN
            fname = relnames<2,rpos>
        END
        progs = fnames<2, f>
        pc = DCOUNT(progs, @SVM)
        FOR p = 1 TO pc
            prog = progs<1, 1, p>
            LOCATE prog IN libvars BY 'AL' SETTING subr THEN
                libTargets<1,-1> = prog
                fnames<4, f, p> = @TRUE
            END ELSE
                binTargets<1, -1> = prog
                subr = @FALSE
            END
            includes = ''
            GOSUB processSource
            IF subr THEN
                libTargets<2,-1> = prog
            END ELSE
                binTargets<2, -1> = prog
            END
            fnames<5, f, p> = prog
            fnames<3, f, p> = CONVERT(includes, @AM:@VM:@SVM, ctrlA:ctrlB:ctrlC)
        NEXT p
    NEXT f
    IF LEN(missing_code) THEN
        CRT 'The following source files could not be read:'
        CRT
        CRT CHANGE(missing_code, @VM, ', ')
        IF NOT(ignoreMissing) THEN STOP
    END
!
! Initialise non-Windows strings
!
    K.Makefile = 'Makefile'
    dir_delim = '/'
    cmd_suffix = ''
    obj_suffix = '.o'
    lib_target = 'lib.el'
    rm_cmd = 'rm'
    foundDollar = @FALSE
!
    clean = 'libobjs':@AM:'binobjs'
    FOR m = 1 TO 2
        targets = ''
        libs = ''
        bins= ''
        catsubs = ''
        makefile = ''
        rebuild = ''
        object_files = ''
        IF m EQ 1 THEN
            makefile<-1> = 'define catlib'
            makefile<-1> = 'echo "" $(foreach fname,$(?),&& CATALOG -L./lib $(firstword $(subst /, ,$(fname))) $(word 2,$(subst /, ,$(fname))))'
            makefile<-1> = 'endef'
        END
        makefile<-1> = @AM:'all: targets'
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
                        dependency := ' ':incl
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
                    makefile<-1> = @AM:object:': ':dependency
                    makefile<-1> = tab:'BASIC ':fname:' ':source
                    IF flag THEN
                        libs<-1> = object
                        subs<-1> = source
                    END ELSE
                        bins<-1> = object
                        target = 'bin':dir_delim:target:cmd_suffix
                        targets<-1> = target
                        makefile<-1> = @AM:target:': ':object
                        makefile<-1> = tab:'CATALOG -o.':dir_delim:'bin ':fname:' ':source
                    END
                END
            NEXT p
            subs = CHANGE(subs, @AM, ' ')
            IF m EQ 2 THEN
                catsubs<-1> = tab:'CATALOG -L.':dir_delim:'lib ':fname:' ':subs
            END
            rebuild<-1> = tab:'CATALOG -L.':dir_delim:'lib -o.':dir_delim:'bin ':fname:' ':CHANGE(progs<1, 1>, @SVM, ' ')
        NEXT f
        makefile<-1> = @AM:libtarget:': ':CHANGE(libs, @AM, ' ')
        IF m EQ 1 THEN
            makefile<-1> = tab:'$(catlib)'
        END ELSE
            makefile<-1> = catsubs
        END
        libobjs = 'libobjs=':CHANGE(libs, @AM, ' ')
        targets = 'alltargets=':CHANGE(targets, @AM, ' ')
        INS @AM:'targets: $(alltargets) ':libtarget BEFORE makefile<1>
        INS @AM:targets BEFORE makefile<1>
        INS 'binobjs=':CHANGE(bins, @AM, ' ') BEFORE makefile<1>
        INS libobjs BEFORE makefile<1>
        makefile<-1> = @AM:'rebuild: $(libobjs) $(binobjs)'
        makefile<-1> = rebuild
        makefile<-1> = @AM:'clean:'
        makefile<-1> = tab:'-':rm_cmd:' /Q .':dir_delim:'lib':dir_delim:'lib*.*'
        nbr_obj_files = DCOUNT(object_files, @AM)
        FOR f = 1 TO nbr_obj_files 
            opts = (IF m EQ 2 THEN ' /F /Q' ELSE '')
            makefile<-1> = tab:'-':rm_cmd:opts:' .':dir_delim:object_files<f>:'*' 
        NEXT f 
        IF foundDollar THEN
            FOR c = 1 TO 2
                cvar = '$(':clean<c>:')'
                IF m = 1 THEN
                    cvar = '$(subst $$,\$$,':cvar:')'
                END
                makefile<-1> = tab:'-':rm_cmd:' ':cvar
            NEXT c
        END
        WRITE makefile ON F.currdir,K.Makefile
!
! Windows settings
!
        K.Makefile = 'Makefile.WIN32'
        dir_delim = '\'
        cmd_suffix = '.exe'
        obj_suffix = '.obj'
        lib_target = 'libdef.def'
        rm_cmd = 'del'
    NEXT m
    makefile = 'nmake -f Makefile.WIN32 %1 %2 %3 %4 %5 %6 %7 %8 %9'
    WRITE makefile ON F.currdir,'make.bat'
    CRT 'Created make.bat, Makefile{.WIN32}'
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
    rc = fnPARSESOURCE(fname, fvars(rpos), prog, includes, missing_code)
    RETURN
