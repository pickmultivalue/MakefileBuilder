! PROGRAM ZUMCATALOG
    CRT 'Processing bins'
    CRT '==============='
    DATA 'ZUMCATEXEC CATALOG -o./bin'
    EXECUTE 'SELECT ZUMCATS WITH *A2 = "[bin"'

    CRT 'Processing libs'
    CRT '==============='
    DATA 'ZUMCATEXEC CATALOG -L./lib'
    EXECUTE 'SELECT ZUMCATS WITH *A2 = "[lib"'
