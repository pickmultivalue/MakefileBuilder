! Program to move a physical file to an encrypted
! drive/partition.
!
    EQU fletters TO 'DI'      ;! possible associated file]suffixes
!
    CALL JBASEParseCommandLine1(args, opts, fname)
!
    hlp='?hH'
    FOR h = 1 TO LEN(hlp)
        letter = hlp[h,1]
        LOCATE '-':letter IN args SETTING hpos THEN
            BREAK
        END ELSE hpos = @FALSE
    NEXT h
!
    IF LEN(fname) EQ 0 AND NOT(hpos) THEN
        letter = '?'
        hpos = @TRUE
    END
!
    IF hpos THEN
        GOSUB showSyntax
        STOP
    END
!
    FINDSTR '-d' IN args SETTING dpos THEN
        encroot = args<dpos>[3,-1]
    END ELSE
        encroot = '/dbms/encrypted'
    END
    OPEN encroot TO f.check ELSE
        IF LEN(encroot) THEN
            CRT encroot:' cannot be opened'
        END ELSE
            GOSUB showSyntax
        END
        STOP
    END
    LOCATE '-v' IN args SETTING verbose ELSE verbose = @FALSE
    LOCATE '-p' IN args SETTING ask ELSE ask = @FALSE
    LOCATE '-r' IN args SETTING revert ELSE revert = @FALSE
    LOCATE '-m' IN args SETTING createMD ELSE createMD = @FALSE
    LOCATE '-t' IN args SETTING testing THEN
        verbose = @TRUE
    END ELSE testing = @FALSE
    sh = @IM:'k'
!
    IF createMD THEN
        OPEN 'MD' TO f.md ELSE STOP 201,'MD'
        OPEN 'SYSTEM' TO f.system ELSE STOP 201,'SYSTEM'
    END

    OPEN fname TO f.file ELSE STOP 201,fname

    INCLUDE JBC.h
!
! Get full path of file
!
    fpath = '' ;! suppress compiler warning

    rc = IOCTL(f.file, JBC_COMMAND_GETFILENAME, fpath)

    CONVERT '/' TO @AM IN fpath
    LOCATE '.' IN fpath SETTING fpos THEN DEL fpath<fpos>
    CONVERT @AM TO '/' IN fpath
    dc = COUNT(fpath, '/')
    dir = FIELD(fpath, '/', dc)
    root = fpath[1, COL2() - 1]
    OPEN root TO f.parent ELSE STOP 201, fpath
!
! Check it hasn't been encrypted
!
    EXECUTE sh:'readlink ':fpath CAPTURING symlink
    IF LEN(symlink) THEN fpath = symlink
    encrypted = (fpath[1, LEN(encroot)] EQ encroot)
    IF encrypted - revert NE 0 THEN
        OPEN encroot:DIR_DELIM_CH:fname THEN
            error = (IF revert THEN 'not' ELSE 'already')
            CRT fname:' is ':error:' encrypted'
        END ELSE
            CRT 'Sub-directory path detected'
        END
        STOP
    END

    IF ask THEN
        question = 'Process ':fname
        GOSUB confirm
        IF NOT(ok) THEN STOP
    END

    fnames = fname
    fpaths = fpath
    FOR l = 1 TO LEN(fletters)
        suffix = ']':fletters[l,1]
        file = fname:suffix
        rc = IOCTL(f.parent, JIOCTL_COMMAND_FINDRECORD, file)
        IF rc GT 0 THEN
            fnames<-1> = file
            fpaths<-1> = fpath:suffix
        END
    NEXT l
    file_count = DCOUNT(fnames, @AM)
!
! Check we have this as an account
!
    IF createMD THEN
        READ realacc FROM f.system, dir ELSE STOP 202,dir
    END
!
    encpath = encroot:'/':dir
    OPEN encpath TO f.check ELSE
        IF revert THEN
            CRT 'Fatal error: cannot open ':encpath
            STOP
        END
        shcmd = 'mkdir ':encpath
        IF ask THEN
            question = shcmd
            GOSUB confirm
        END ELSE ok = @TRUE
        IF ok THEN
            IF testing THEN
                CRT shcmd
            END ELSE
                IF verbose THEN CRT shcmd
                EXECUTE sh:shcmd CAPTURING nada
                IF verbose THEN CRT nada
            END
        END
!
! Check we can open encpath
!
        OPEN encpath TO f.check ELSE
            IF testing THEN
                CRT encpath:' would be created'
            END ELSE
                STOP 201, encpath
            END
        END
    END
!
! Now make SYSTEM entry
!
    IF createMD THEN
        encdir = 'ENCRYPTED.':dir
        READV check FROM f.system, encdir, 2 THEN
            IF check NE encpath THEN
                CRT 'Error: SYSTEM entry for ':encdir:' = ':check
                STOP
            END
        END ELSE
            IF revert THEN
                CRT 'Fatal error: cannot read ':encdir:' from SYSTEM'
                STOP
            END ELSE
                realacc<2> = encpath
                realacc<22> = encpath
                IF ask THEN
                    question = 'Create SYSTEM,':encdir
                    GOSUB confirm
                END ELSE ok = @TRUE
                IF ok THEN
                    IF testing THEN
                        CRT '(testmode) ':
                    END ELSE
                        WRITE realacc ON f.system, encdir
                    END
                    IF verbose THEN
                        CRT encdir:' written to SYSTEM'
                    END
                END
            END
        END

        READ mditem FROM f.md, fname ELSE
            IF ask THEN
                qop = (IF revert THEN 'Delete' ELSE 'Create')
                question = qop:' MD,':fname
                GOSUB confirm
            END ELSE ok = @TRUE
            IF ok THEN
                mditem = 'Q':@AM:dir:@AM:fname
                IF testing THEN
                    CRT '(testmode) ':
                END ELSE
                    IF revert THEN
                        DELETE f.md, fname
                    END ELSE
                        WRITE mditem ON f.md, fname
                    END
                END
                IF verbose THEN
                    qop = (IF revert THEN 'removed from' ELSE 'written to')
                    CRT fname:' ':qop:' MD'
                END
            END
            IF NOT(testing) THEN
!
! Check we can still open the file
!
                OPEN fname TO f.mdcheck ELSE
                    IF NOT(revert) THEN
                        DELETE f.md, fname
                    END
                    CRT 'Failed to open ':CHANGE(mditem, @AM, ',')
                    STOP
                END
            END
        END
!
! Change mditem to encrypted
!
        mditem<2> = (IF revert THEN dir ELSE encdir)
    END
!
! Move the original file to the encrypted partition
!
    IF revert THEN
        toDir = root
        fromDir = encpath
        shcmd = 'rm ':toDir:'/':fname:'{]*}'
        IF ask THEN
            question = shcmd
            GOSUB confirm
        END ELSE ok = @TRUE
        IF ok THEN
            FOR f = 1 TO file_count
                shcmd = 'rm ':toDir:'/':fnames<f>
                IF testing THEN
                    CRT shcmd
                END ELSE
                    EXECUTE sh:shcmd CAPTURING nada
                    IF verbose THEN GOSUB displayNada
                END
            NEXT f
        END
    END ELSE
        fromDir = root
        toDir = encpath
    END
    shcmd = 'mv -v ':fromDir:'/':fname:'{]*} ':toDir
    IF ask THEN
        question = shcmd
        GOSUB confirm
    END ELSE ok = @TRUE
    IF ok THEN
        FOR f = 1 TO file_count
            shcmd = 'mv -v ':fromDir:'/':fnames<f>:' ':toDir
            IF testing THEN
                CRT shcmd
            END ELSE
                EXECUTE sh:shcmd CAPTURING nada
                IF verbose THEN GOSUB displayNada
            END
            IF NOT(revert) THEN
                shcmd = 'ln -s ':encpath:'/':fnames<f>:' ':fpaths<f>
                IF testing THEN
                    CRT shcmd
                END ELSE
                    EXECUTE sh:shcmd CAPTURING nada
                    IF verbose THEN GOSUB displayNada
                END
            END
        NEXT f
    END
!
! Now write out the new MD and check we can still open
!
    IF createMD THEN
        IF ask THEN
            question = 'Update MD,':fname
            GOSUB confirm
        END ELSE ok = @TRUE
        IF ok THEN
            IF testing THEN
                CRT 'WRITE ':CHANGE(mditem, @AM, '^'):' ON MD,':fname
            END ELSE
                WRITE mditem ON f.md, fname
                OPEN fname TO f.file ELSE STOP 201,fname
                IF verbose THEN CRT 'MD,':fname:' updated'
            END
        END
    END
!
    CRT 'done'
    STOP
!
confirm:
    CRT question:' (Y/<N>/X)':
    INPUT resp,1_
    resp = UPCASE(resp)
    IF resp EQ 'X' THEN STOP
    ok = UPCASE(resp) EQ 'Y'
    RETURN
!
displayNada:
!
    loc = 0
    LOOP
        REMOVE lnada FROM nada AT loc SETTING delim
        lnada = OCONV(lnada, 'MCP$')
        CONVERT '$' TO '' IN lnada
        CRT lnada
    WHILE delim DO REPEAT
    RETURN
!
showSyntax:
!
    CRT 'Syntax: move2enc [-d<enc_dir>] [-v] [-p] [-t] [-?,h,H] <filename>'
    CRT 'where: d - destination'
    CRT '       m - create MD (and SYSTEM)'
    CRT '       p - prompt'
    CRT '       t - test mode'
    CRT '       v - verbose'
    CRT '     ?|h - syntax'
    CRT '       H - full help'
    IF letter EQ 'H' THEN
        CRT
        CRT 'This command moves a file from its normal location'
        CRT 'to an encrypted disk.'
        CRT
        CRT '(e.g. mv /dbms/<acc>/<filename>':
        CRT ' -> /dbms/encrypted/<acc>/<filename>.'
        CRT
        CRT 'A SYSTEM entry and Q pointer will also'
        CRT 'be created to point to the new file location'
        CRT 'as well as a softlink'
        CRT
    END
    RETURN
