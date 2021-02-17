    FUNCTION fnCONVBP2DIR(fname, F.var)
!
! Convert a file from Hash to DIR
!
    INCLUDE JBC.h
!
    OPEN fname TO F.var THEN
        status = ''
        rc = IOCTL(F.var,JIOCTL_COMMAND_FILESTATUS,status)
        IF status<1> EQ 'UD' THEN RETURN 1 ;! already a dir
    END ELSE
        RETURN 0
    END
!
    fullPath = ''
    IF IOCTL(F.var,JBC_COMMAND_GETFILENAME,fullPath) ELSE
        RETURN 0
    END
!
    tempDir = fullPath:'%tmp_dir%'
    EXECUTE 'CREATE-FILE DATA ':tempDir:' TYPE=UD' CAPTURING io
    OPEN tempDir TO F.target ELSE
        RETURN 0
    END
!
    locked_files = ''
    SELECT F.var
    LOOP WHILE READNEXT prog DO
        READU code FROM F.var,prog LOCKED
            locked_files<-1> = prog
        END THEN
            WRITE code ON F.target, prog
        END
    REPEAT
!
    CLOSE F.var
    CLOSE F.target
    IF LEN(locked_files) THEN
        CRT 'The following files are locked:'
        CRT
        CRT CHANGE(locked_files, @AM, @CR:@LF)
        INPUT cont
        RETURN 0
    END
    saveHash = fullPath:'%old%'
    PCPERFORM MOVE_CMD:' ':fullPath:' ':saveHash
    PCPERFORM MOVE_CMD:' ':tempDir:' ':fullPath
    OPEN fname TO F.var THEN
        PCPERFORM 'DELETE-FILE DATA ':saveHash
    END ELSE
        RETURN 0
    END
!
    RETURN 1
