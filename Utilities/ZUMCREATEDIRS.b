! PROGRAM ZUMCREATEDIRS
    dirs = ''
    dirs<-1> = 'ZUMCATS'
    dirs<-1> = 'ZUMLIBS'
    dirs<-1> = 'BADCATS'
    dirs<-1> = 'BASICFAILS'
    dc = DCOUNT(dirs, @AM)
    FOR d = 1 TO dc
        PCPERFORM 'mkdir ':dirs<d>
    NEXT d
