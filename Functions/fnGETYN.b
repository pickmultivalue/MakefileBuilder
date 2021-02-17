  FUNCTION fnGETYN(question, options)
!
  IF UNASSIGNED(question) THEN question = ''
  IF UNASSIGNED(options) THEN options = ''
!
  IF LEN(options) EQ 0 THEN options = 'Y':@VM:'N'
!
  nullResp = options<2>
  LOCATE nullResp IN options<1> SETTING npos ELSE
      nullResp = ''
      npos = @FALSE
  END
!
  dispOptions = options<1>
  IF npos THEN
      dispOptions<1, npos> = '<':dispOptions<1, npos>:'>'
  END
!
  emulation = ''
  rc = GETENV('JBCEMULATE', emulation)
  IF INDEX(UPCASE(emulation), 'D3', 1) THEN
      rc = 2092
  END ELSE
      rc = 26
  END
  promptChar = SYSTEM(rc)
  CRT question:' (':CHANGE(dispOptions, @VM, '/'):')':
!
  LOOP
      INPUT resp:_
      IF LEN(resp) EQ 0 THEN resp = nullResp
      LOCATE resp IN options<1> SETTING rpos THEN BREAK
      l = LEN(promptChar:resp):
      bs = STR(CHAR(8), l)
      CRT bs:SPACE(l):bs:CHAR(7):
  REPEAT
  CRT
!
  RETURN(resp)
