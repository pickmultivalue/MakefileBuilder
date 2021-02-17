! PROGRAM CONVBP2DIR
!
! Convert a BP hash file to a DIR and create an OBJECT level
!
    DEFFUN fnOPEN()
    DEFFUN fnCONVBP2DIR()
    DEFFUN fnMOVEOBJECT()
!
    fname = SENTENCE(1)
    IF fnCONVBP2DIR(fname, f.bp) THEN
        objFile = fname:',OBJECT'
        EXECUTE 'CREATE-FILE DATA ':objFile:' TYPE=UD'
        error = NOT(fnOPEN(objFile, f.object, ''))
        IF NOT(error) THEN
            IF NOT(fnMOVEOBJECT(f.bp, f.object)) THEN
                CRT 'Error moving object code for ':fname
                CRT 'Aborting.'
                STOP
            END
        END
    END ELSE
        CRT 'CONVBP2DIR failed'
    END
