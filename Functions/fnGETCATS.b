    FUNCTION fnGETCATS(type)
    fnames = ''
    zumcats = 'ZUMCATS'
    zumlibs = 'ZUMLIBS'
    search_files = ''
    IF type NE 'BINS' THEN search_files<-1> = zumlibs
    IF type NE 'LIBS' THEN search_files<-1> = zumcats 
    dc = DCOUNT(search_files, @AM)
    FOR f = 1 TO dc
        search_file = search_files<f>
        OPEN search_file TO F.search_file ELSE STOP 201, search_file
        IF NOT(SYSTEM(11)) THEN
            EXECUTE 'SSELECT ':search_file:' BY *A1 BY *A2' CAPTURING io
        END
        LOOP WHILE READNEXT prog DO
            READ catdef FROM F.search_file,prog ELSE CONTINUE
            fname = catdef<1>
            LOCATE fname IN fnames<1> BY 'AL' SETTING fpos ELSE
                INS fname BEFORE fnames<1,fpos>
                INS '' BEFORE fnames<2,fpos>
            END
            LOCATE prog IN fnames<2,fpos> BY 'AL' SETTING ppos ELSE
                INS prog BEFORE fnames<2,fpos,ppos>
            END
        REPEAT
    NEXT f
    RETURN fnames
