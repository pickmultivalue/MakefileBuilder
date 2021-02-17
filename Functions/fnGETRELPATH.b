    FUNCTION fnGETRELPATH(fvar, pwd)
!
    INCLUDE JBC.h
!
    IF UNASSIGNED(pwd) THEN pwd = ''
    IF LEN(pwd) EQ 0 THEN
        rc = GETENV('PWD',pwd)
    END
!
    pwd = CHANGE(pwd, DIR_DELIM_CH, @AM)
    pwd_count = DCOUNT(pwd, @AM)
!
    rc = IOCTL(fvar, JBC_COMMAND_GETFILENAME, fileName)
    fileName = CHANGE(fileName, DIR_DELIM_CH, @AM)
    pwd_check = pwd
    FOR p = 1 TO pwd_count
        IF fileName<1> NE pwd_check<1> THEN BREAK
        DEL fileName<1>
        DEL pwd_check<1>
    NEXT p
    fileName = CHANGE(fileName, @AM, DIR_DELIM_CH)
!
    RETURN(fileName)
