     FUNCTION fnTIMESTAMP(FPATH)
     $options jabba 
     RESULT = ''
 #inline
     struct stat attrib;
     struct tm *stats;
     char tstamp[30];
     VAR * vRecordKey = JVAR(FPATH);
     VAR * vResult = JVAR(RESULT);
     char * RecordKey = CONV_SFB(vRecordKey);
     if (stat(RecordKey, &attrib) == 0) {
         stats = localtime(&(attrib.st_mtime));
         strftime(tstamp, 30, "%d %b %Y %H:%M:%S", stats);
         STORE_VBS(vResult, (STRING*)tstamp);
     }
 #endinline
     IF LEN(RESULT) THEN
         idate = ICONV(FIELD(RESULT, ' ', 1, 3), 'D')
         itime = ICONV(RESULT[COl2()+1,-1], 'MTS')
         RESULT = idate:@AM:itime
     END
     RETURN RESULT
