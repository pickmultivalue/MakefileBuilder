! PROGRAM ZUMCATALOG
    OPEN 'ZUMCATS' TO F.ZUMCATS ELSE STOP 201, 'ZUMCATS'
    IF NOT(SYSTEM(11)) THEN
        EXECUTE 'SSELECT ZUMCATS BY *A1 BY *A2' CAPTURING io
    END 
    fnames = ''
    LOOP WHILE READNEXT prog DO
        READ catdef FROM F.ZUMCATS,prog ELSE CONTINUE
        fname = catdef<1>
        LOCATE fname IN fnames<1> BY 'AL' SETTING fpos ELSE
            INS fname BEFORE fnames<1,fpos>
            INS '' BEFORE fnames<2,fpos>
        END
        LOCATE prog IN fnames<2,fpos> BY 'AL' SETTING ppos ELSE
            INS prog BEFORE fnames<2,fpos,ppos>
        END
    REPEAT

    fc = DCOUNT(fnames<1>, @VM)
    FOR f = 1 TO fc
        fname = fnames<1, f>
        progs = CHANGE(fnames<2,f>, @SVM, ' ')
        EXECUTE 'BASIC ':fname:' ':progs
        EXECUTE 'CATALOG -L./lib -o./bin ':fname:' ':progs
    NEXT f 
