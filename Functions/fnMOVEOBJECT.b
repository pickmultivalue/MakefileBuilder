    FUNCTION fnMOVEOBJECT(f.source, f.object)
!
    INCLUDE JBC.h
!
! Move object code from BP to BP,OBJECT
!
    match = "0X":SQUOTE(FILE_SUFFIX_OBJ)
!
! Prepare file handles for binary read/write
!
    rc1 = IOCTL(f.source,JIOCTL_COMMAND_CONVERT,"RB")
    rc2 = IOCTL(f.object,JIOCTL_COMMAND_CONVERT,"WB")
    IF NOT(rc1) OR NOT(rc2) THEN
        RETURN 0
    END
!
    SELECT f.source
    LOOP WHILE READNEXT prog DO
        IF prog[1,1] EQ '$' OR prog MATCHES match THEN
            READ obj FROM f.source,prog THEN
                WRITE obj ON f.object,prog ON ERROR
                    RETURN 0
                END
                DELETE f.source,prog
            END ELSE
                RETURN 0
            END
        END
    REPEAT
!
    RETURN(1)
