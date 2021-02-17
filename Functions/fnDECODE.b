  FUNCTION fnDECODE(subr)
  subr = CHANGE(subr, 'JBC_', '')
  l = LEN(subr)
  result = ''
  FOR p = 1 TO l
      c = subr[p,1]
      IF c EQ '_' THEN
          c = CHAR(OCONV(subr[p+1,2],'MCXD'))
          p += 2
      END
      result := c
  NEXT p
!
  RETURN(result)
