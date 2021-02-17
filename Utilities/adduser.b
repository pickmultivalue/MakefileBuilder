! PROGRAM adduser
    CALL JBASEParseCommandLine1(args, opts, user)
    PROMPT ''
    CRT 'password: ':
    INPUT passwd
    IF LEN(passwd) EQ 0 THEN
        CRT 'Password required'
