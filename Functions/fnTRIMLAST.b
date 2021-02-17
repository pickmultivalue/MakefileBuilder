    FUNCTION fnTRIMLAST(value, delim)
    dc = DCOUNT(value, delim)
    IF dc GT 1 THEN
        value = FIELD(value, delim, 1, dc - 1)
    END
    RETURN (value)
