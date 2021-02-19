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
    FOR p = 1 TO pwd_count
        IF fileName<p> NE ampwd<p> THEN BREAK
        fileName<p> = '..'
    NEXT p
    fileName = CHANGE(fileName, @AM, DIR_DELIM_CH)
!
    RETURN(fileName)
