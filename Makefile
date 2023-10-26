.PHONY : all targets

all: targets

define catlib
echo "" $(foreach fname,$(?),&& CATALOG -L./lib $(firstword $(subst /, ,$(fname))) $(word 2,$(subst /, ,$(fname))))
endef
lib1=./lib/fnCONVBP2DIR.so ./lib/fnDECODE.so ./lib/fnGETCATS.so ./lib/fnGETRELPATH.so ./lib/fnGETYN.so ./lib/fnLAST.so ./lib/fnMOVEOBJECT.so ./lib/fnOPEN.so ./lib/fnSPLITSENT.so ./lib/fnTIMESTAMP.so ./lib/fnTRIMLAST.so ./lib/fnPARSESOURCE.so
libobj1=Functions]MOBJECT/fnCONVBP2DIR.so Functions]MOBJECT/fnDECODE.so Functions]MOBJECT/fnGETCATS.so Functions]MOBJECT/fnGETRELPATH.so Functions]MOBJECT/fnGETYN.so Functions]MOBJECT/fnLAST.so Functions]MOBJECT/fnMOVEOBJECT.so Functions]MOBJECT/fnOPEN.so Functions]MOBJECT/fnSPLITSENT.so Functions]MOBJECT/fnTIMESTAMP.so Functions]MOBJECT/fnTRIMLAST.so jBC_Makefile]MOBJECT/fnPARSESOURCE.so
bin1=./bin/CONVBP2DIR ./bin/JUTIL_BASIC ./bin/JUTIL_BASICFAILS ./bin/JUTIL_CATALOG ./bin/JUTIL_CATEXEC ./bin/JUTIL_CHECKBAS ./bin/JUTIL_CREATEDIRS ./bin/JUTIL_BLDMAKE ./bin/JUTIL_GETCATS
binobj1=Utilities]MOBJECT/CONVBP2DIR.so Utilities]MOBJECT/JUTIL_BASIC.so Utilities]MOBJECT/JUTIL_BASICFAILS.so Utilities]MOBJECT/JUTIL_CATALOG.so Utilities]MOBJECT/JUTIL_CATEXEC.so Utilities]MOBJECT/JUTIL_CHECKBAS.so Utilities]MOBJECT/JUTIL_CREATEDIRS.so jBC_Makefile]MOBJECT/JUTIL_BLDMAKE.so jBC_Makefile]MOBJECT/JUTIL_GETCATS.so
binobjs=$(binobj1)
libobjs=$(libobj1)

alllibs: $(libobjs)
	make -s $(lib1)

targets: allbins alllibs

allbins: $(binobjs)
	make -s $(bin1)


Functions]MOBJECT/fnCONVBP2DIR.so: Functions/fnCONVBP2DIR.b
	BASIC Functions fnCONVBP2DIR.b

Functions]MOBJECT/fnDECODE.so: Functions/fnDECODE.b
	BASIC Functions fnDECODE.b

Functions]MOBJECT/fnGETCATS.so: Functions/fnGETCATS.b
	BASIC Functions fnGETCATS.b

Functions]MOBJECT/fnGETRELPATH.so: Functions/fnGETRELPATH.b
	BASIC Functions fnGETRELPATH.b

Functions]MOBJECT/fnGETYN.so: Functions/fnGETYN.b
	BASIC Functions fnGETYN.b

Functions]MOBJECT/fnLAST.so: Functions/fnLAST.b
	BASIC Functions fnLAST.b

Functions]MOBJECT/fnMOVEOBJECT.so: Functions/fnMOVEOBJECT.b
	BASIC Functions fnMOVEOBJECT.b

Functions]MOBJECT/fnOPEN.so: Functions/fnOPEN.b
	BASIC Functions fnOPEN.b

Functions]MOBJECT/fnSPLITSENT.so: Functions/fnSPLITSENT.b
	BASIC Functions fnSPLITSENT.b

Functions]MOBJECT/fnTIMESTAMP.so: Functions/fnTIMESTAMP.b
	BASIC Functions fnTIMESTAMP.b

Functions]MOBJECT/fnTRIMLAST.so: Functions/fnTRIMLAST.b
	BASIC Functions fnTRIMLAST.b

./lib/fnCONVBP2DIR.so: Functions]MOBJECT/fnCONVBP2DIR.so
	CATALOG -L./lib Functions fnCONVBP2DIR.b

./lib/fnDECODE.so: Functions]MOBJECT/fnDECODE.so
	CATALOG -L./lib Functions fnDECODE.b

./lib/fnGETCATS.so: Functions]MOBJECT/fnGETCATS.so
	CATALOG -L./lib Functions fnGETCATS.b

./lib/fnGETRELPATH.so: Functions]MOBJECT/fnGETRELPATH.so
	CATALOG -L./lib Functions fnGETRELPATH.b

./lib/fnGETYN.so: Functions]MOBJECT/fnGETYN.so
	CATALOG -L./lib Functions fnGETYN.b

./lib/fnLAST.so: Functions]MOBJECT/fnLAST.so
	CATALOG -L./lib Functions fnLAST.b

./lib/fnMOVEOBJECT.so: Functions]MOBJECT/fnMOVEOBJECT.so
	CATALOG -L./lib Functions fnMOVEOBJECT.b

./lib/fnOPEN.so: Functions]MOBJECT/fnOPEN.so
	CATALOG -L./lib Functions fnOPEN.b

./lib/fnSPLITSENT.so: Functions]MOBJECT/fnSPLITSENT.so
	CATALOG -L./lib Functions fnSPLITSENT.b

./lib/fnTIMESTAMP.so: Functions]MOBJECT/fnTIMESTAMP.so
	CATALOG -L./lib Functions fnTIMESTAMP.b

./lib/fnTRIMLAST.so: Functions]MOBJECT/fnTRIMLAST.so
	CATALOG -L./lib Functions fnTRIMLAST.b

Utilities]MOBJECT/CONVBP2DIR.so: Utilities/CONVBP2DIR.b
	BASIC Utilities CONVBP2DIR.b

./bin/CONVBP2DIR: Utilities]MOBJECT/CONVBP2DIR.so
	CATALOG -o./bin Utilities CONVBP2DIR.b

Utilities]MOBJECT/JUTIL_BASIC.so: Utilities/JUTIL_BASIC.b
	BASIC Utilities JUTIL_BASIC.b

./bin/JUTIL_BASIC: Utilities]MOBJECT/JUTIL_BASIC.so
	CATALOG -o./bin Utilities JUTIL_BASIC.b

Utilities]MOBJECT/JUTIL_BASICFAILS.so: Utilities/JUTIL_BASICFAILS.b
	BASIC Utilities JUTIL_BASICFAILS.b

./bin/JUTIL_BASICFAILS: Utilities]MOBJECT/JUTIL_BASICFAILS.so
	CATALOG -o./bin Utilities JUTIL_BASICFAILS.b

Utilities]MOBJECT/JUTIL_CATALOG.so: Utilities/JUTIL_CATALOG.b
	BASIC Utilities JUTIL_CATALOG.b

./bin/JUTIL_CATALOG: Utilities]MOBJECT/JUTIL_CATALOG.so
	CATALOG -o./bin Utilities JUTIL_CATALOG.b

Utilities]MOBJECT/JUTIL_CATEXEC.so: Utilities/JUTIL_CATEXEC.b
	BASIC Utilities JUTIL_CATEXEC.b

./bin/JUTIL_CATEXEC: Utilities]MOBJECT/JUTIL_CATEXEC.so
	CATALOG -o./bin Utilities JUTIL_CATEXEC.b

Utilities]MOBJECT/JUTIL_CHECKBAS.so: Utilities/JUTIL_CHECKBAS.b
	BASIC Utilities JUTIL_CHECKBAS.b

./bin/JUTIL_CHECKBAS: Utilities]MOBJECT/JUTIL_CHECKBAS.so
	CATALOG -o./bin Utilities JUTIL_CHECKBAS.b

Utilities]MOBJECT/JUTIL_CREATEDIRS.so: Utilities/JUTIL_CREATEDIRS.b
	BASIC Utilities JUTIL_CREATEDIRS.b

./bin/JUTIL_CREATEDIRS: Utilities]MOBJECT/JUTIL_CREATEDIRS.so
	CATALOG -o./bin Utilities JUTIL_CREATEDIRS.b

jBC_Makefile]MOBJECT/JUTIL_BLDMAKE.so: jBC_Makefile/JUTIL_BLDMAKE.b
	BASIC jBC_Makefile JUTIL_BLDMAKE.b

./bin/JUTIL_BLDMAKE: jBC_Makefile]MOBJECT/JUTIL_BLDMAKE.so
	CATALOG -o./bin jBC_Makefile JUTIL_BLDMAKE.b

jBC_Makefile]MOBJECT/JUTIL_GETCATS.so: jBC_Makefile/JUTIL_GETCATS.b
	BASIC jBC_Makefile JUTIL_GETCATS.b

./bin/JUTIL_GETCATS: jBC_Makefile]MOBJECT/JUTIL_GETCATS.so
	CATALOG -o./bin jBC_Makefile JUTIL_GETCATS.b

jBC_Makefile]MOBJECT/fnPARSESOURCE.so: jBC_Makefile/fnPARSESOURCE.b
	BASIC jBC_Makefile fnPARSESOURCE.b

./lib/fnPARSESOURCE.so: jBC_Makefile]MOBJECT/fnPARSESOURCE.so
	CATALOG -L./lib jBC_Makefile fnPARSESOURCE.b

libs1: $(libobj1)
	$(catlib)

rebuild: $(libobjs) $(binobjs)
	CATALOG -o./bin Utilities CONVBP2DIR.b JUTIL_BASIC.b JUTIL_BASICFAILS.b JUTIL_CATALOG.b JUTIL_CATEXEC.b JUTIL_CHECKBAS.b JUTIL_CREATEDIRS.b
	CATALOG -o./bin jBC_Makefile JUTIL_BLDMAKE.b JUTIL_GETCATS.b
	make -s libs1

clean:
	-rm ./lib/lib*.*
	-rm ./Functions]MOBJECT/*
	-rm ./Utilities]MOBJECT/*
	-rm ./jBC_Makefile]MOBJECT/*
