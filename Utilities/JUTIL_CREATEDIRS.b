! PROGRAM JUTIL_CREATEDIRS
    dirs = ''
    dirs<-1> = 'JUTLMKCATS'
    dirs<-1> = 'JUTLMKLIBS'
    dirs<-1> = 'BADCATS'
    dirs<-1> = 'BASICFAILS'
    dc = DCOUNT(dirs, @AM)
    FOR d = 1 TO dc
        PCPERFORM 'mkdir ':dirs<d>
    NEXT d
