    FUNCTION fnGETRELPATH(fvar, pwd)
!
    INCLUDE JBC.h
!
    IF UNASSIGNED(pwd) THEN pwd = ''
    IF LEN(pwd) EQ 0 THEN
        rc = GETENV('PWD',pwd)
    END
!
    rc = IOCTL(fvar, JBC_COMMAND_GETFILENAME, fileName)
    fileName = CHANGE(fileName, pwd:DIR_DELIM_CH, '')
!
    ampwd = CHANGE(pwd, DIR_DELIM_CH, @AM)
    pwd_count = DCOUNT(ampwd, @AM)
    fileName = CHANGE(fileName, DIR_DELIM_CH, @AM)
    IF COUNT(fileName, @AM) THEN
        IF fileName<1> MATCHES "1A':'" AND UPCASE(fileName<1>) = UPCASE(ampwd<1>) THEN
            fileName<1> = ''
            ampwd<1> = ''
        END
        FOR p = 1 TO pwd_count
            IF fileName<1> NE ampwd<1> THEN BREAK
            DEL fileName<1>
            DEL ampwd<1>
        NEXT p

        FOR levl = p TO pwd_count
            INS '..' BEFORE fileName<1>
        NEXT levl
        fileName = CHANGE(fileName, @AM, DIR_DELIM_CH)
    END
!
    RETURN(fileName)


