  FUNCTION fnSPLITSENT(sent, wc)
!
! Split a string or array into an AM delimited array
! each containing "wc" words
!
  nsent = sent
  CONVERT @AM:@VM:@SVM TO '   ' IN nsent
  nsent = TRIM(nsent)
  dc = DCOUNT(nsent, ' ')
  FOR w = 1 TO dc STEP wc
      brkpos = INDEX(nsent, ' ', w + wc - 1)
      IF NOT(brkpos) THEN BREAK
      nsent = nsent[1, brkpos-1]:@AM:nsent[brkpos+1, LEN(nsent)]
  NEXT w

  RETURN nsent
