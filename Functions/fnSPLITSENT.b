  FUNCTION fnSPLITSENT(sent, wc)
!
! Split a string or array into an AM delimited array
! each containing "wc" words
!
  nsent = sent
  CONVERT @AM:@VM:@SVM TO '   ' IN nsent
  nsent = TRIM(nsent)
  dc = DCOUNT(nsent, ' ')
  w = 0
  FOR c = 1 TO LEN(nsent)
      ch = nsent[c,1]
      IF ch EQ ' ' THEN
          w++
          IF w EQ wc THEN
              nsent[c,1] = @AM
              w = 0
          END
      END
  NEXT w

  RETURN nsent
