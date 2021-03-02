! PROGRAM ZUMCATEXEC
    DEFFUN fnGETCATS()
    DEFFUN fnSPLITSENT()
    cmd = FIELD(@SENTENCE,' ', 2, 99)
    fnames = fnGETCATS()
    fc = DCOUNT(fnames<1>, @VM)
    CRT 'Processing ':DQUOTE(cmd):' on the following files: ':
    CRT CHANGE(fnames<1>, @VM, ', ')
    CRT 
    FOR f = 1 TO fc
        fname = fnames<1, f>
        progs = fnSPLITSENT(fnames<2, f>, 100)
        pc = DCOUNT(progs, @AM)
        FOR p = 1 TO pc 
            CRT 'Processing ':fname:' ':progs<p>
            EXECUTE cmd:' ':fname:' ':progs<p>:' (O' 
        NEXT p
    NEXT f
