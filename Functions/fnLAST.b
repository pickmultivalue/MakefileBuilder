    FUNCTION fnLAST(value, delim)
    dc = DCOUNT(value, delim)
    IF dc GT 1 THEN
        value = FIELD(value, delim, dc)
    END
    RETURN (value)
