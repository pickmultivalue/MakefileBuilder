    FUNCTION fnOPEN(filename, fvar, failopt)
!
    INCLUDE JBC.h
    DEFFUN fnGETRELPATH()
!
    IF UNASSIGNED(failopt) THEN failopt = ''
    getRealFile = failopt<2> EQ @TRUE
    failopt = failopt<1>
!
    OPEN filename TO fvar THEN
        IF getRealFile THEN
            filename = fnGETRELPATH(fvar, '')
        END
        rc = 1
    END ELSE
        rc = 201
!
        BEGIN CASE
            CASE failopt EQ 1
                STOP rc
            CASE failopt EQ 2
                ABORT rc
            CASE 1
                failopt = 'Cannot open ':filename
                rc = 0
        END CASE
    END
!
    RETURN(rc)
