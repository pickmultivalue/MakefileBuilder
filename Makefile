.PHONY : all targets


define catlib
echo "" $(foreach fname,$(?),&& CATALOG -L./lib $(firstword $(subst /, ,$(fname))) $(word 2,$(subst /, ,$(fname))))
endef
libobj1=Functions]MOBJECT/fnCONVBP2DIR.o Functions]MOBJECT/fnDECODE.o Functions]MOBJECT/fnGETCATS.o Functions]MOBJECT/fnGETRELPATH.o Functions]MOBJECT/fnGETYN.o Functions]MOBJECT/fnLAST.o Functions]MOBJECT/fnMOVEOBJECT.o Functions]MOBJECT/fnOPEN.o Functions]MOBJECT/fnSPLITSENT.o Functions]MOBJECT/fnTIMESTAMP.o Functions]MOBJECT/fnTRIMLAST.o jBC_Makefile]MOBJECT/fnPARSESOURCE.o
bin1=./bin/CONVBP2DIR ./bin/ZUMBASIC ./bin/ZUMBASICFAILS ./bin/ZUMCATALOG ./bin/ZUMCATEXEC ./bin/ZUMCHECKBAS ./bin/ZUMCREATEDIRS ./bin/ZUMBLDMAKE ./bin/ZUMGETCATS
binobj1=Utilities]MOBJECT/CONVBP2DIR.o Utilities]MOBJECT/ZUMBASIC.o Utilities]MOBJECT/ZUMBASICFAILS.o Utilities]MOBJECT/ZUMCATALOG.o Utilities]MOBJECT/ZUMCATEXEC.o Utilities]MOBJECT/ZUMCHECKBAS.o Utilities]MOBJECT/ZUMCREATEDIRS.o jBC_Makefile]MOBJECT/ZUMBLDMAKE.o jBC_Makefile]MOBJECT/ZUMGETCATS.o
binobjs=$(binobj1)
libobjs=$(libobj1)

alllibs: $(libobjs)
	make lib/lib.el


all: targets

targets: allbins alllibs

allbins: $(binobjs)
	make $(bin1)


Functions]MOBJECT/fnCONVBP2DIR.o: Functions/fnCONVBP2DIR.b
	BASIC Functions fnCONVBP2DIR.b

Functions]MOBJECT/fnDECODE.o: Functions/fnDECODE.b
	BASIC Functions fnDECODE.b

Functions]MOBJECT/fnGETCATS.o: Functions/fnGETCATS.b
	BASIC Functions fnGETCATS.b

Functions]MOBJECT/fnGETRELPATH.o: Functions/fnGETRELPATH.b
	BASIC Functions fnGETRELPATH.b

Functions]MOBJECT/fnGETYN.o: Functions/fnGETYN.b
	BASIC Functions fnGETYN.b

Functions]MOBJECT/fnLAST.o: Functions/fnLAST.b
	BASIC Functions fnLAST.b

Functions]MOBJECT/fnMOVEOBJECT.o: Functions/fnMOVEOBJECT.b
	BASIC Functions fnMOVEOBJECT.b

Functions]MOBJECT/fnOPEN.o: Functions/fnOPEN.b
	BASIC Functions fnOPEN.b

Functions]MOBJECT/fnSPLITSENT.o: Functions/fnSPLITSENT.b
	BASIC Functions fnSPLITSENT.b

Functions]MOBJECT/fnTIMESTAMP.o: Functions/fnTIMESTAMP.b
	BASIC Functions 

Functions]MOBJECT/fnTRIMLAST.o: Functions/fnTRIMLAST.b
	BASIC Functions fnTRIMLAST.b

Utilities]MOBJECT/CONVBP2DIR.o: Utilities/CONVBP2DIR.b
	BASIC Utilities CONVBP2DIR.b

./bin/CONVBP2DIR: Utilities]MOBJECT/CONVBP2DIR.o
	CATALOG -o./bin Utilities CONVBP2DIR.b

Utilities]MOBJECT/ZUMBASIC.o: Utilities/ZUMBASIC.b
	BASIC Utilities ZUMBASIC.b

./bin/ZUMBASIC: Utilities]MOBJECT/ZUMBASIC.o
	CATALOG -o./bin Utilities ZUMBASIC.b

Utilities]MOBJECT/ZUMBASICFAILS.o: Utilities/ZUMBASICFAILS.b
	BASIC Utilities ZUMBASICFAILS.b

./bin/ZUMBASICFAILS: Utilities]MOBJECT/ZUMBASICFAILS.o
	CATALOG -o./bin Utilities ZUMBASICFAILS.b

Utilities]MOBJECT/ZUMCATALOG.o: Utilities/ZUMCATALOG.b
	BASIC Utilities ZUMCATALOG.b

./bin/ZUMCATALOG: Utilities]MOBJECT/ZUMCATALOG.o
	CATALOG -o./bin Utilities ZUMCATALOG.b

Utilities]MOBJECT/ZUMCATEXEC.o: Utilities/ZUMCATEXEC.b
	BASIC Utilities ZUMCATEXEC.b

./bin/ZUMCATEXEC: Utilities]MOBJECT/ZUMCATEXEC.o
	CATALOG -o./bin Utilities ZUMCATEXEC.b

Utilities]MOBJECT/ZUMCHECKBAS.o: Utilities/ZUMCHECKBAS.b
	BASIC Utilities ZUMCHECKBAS.b

./bin/ZUMCHECKBAS: Utilities]MOBJECT/ZUMCHECKBAS.o
	CATALOG -o./bin Utilities ZUMCHECKBAS.b

Utilities]MOBJECT/ZUMCREATEDIRS.o: Utilities/ZUMCREATEDIRS.b
	BASIC Utilities ZUMCREATEDIRS.b

./bin/ZUMCREATEDIRS: Utilities]MOBJECT/ZUMCREATEDIRS.o
	CATALOG -o./bin Utilities ZUMCREATEDIRS.b

jBC_Makefile]MOBJECT/ZUMBLDMAKE.o: jBC_Makefile/ZUMBLDMAKE.b
	BASIC jBC_Makefile ZUMBLDMAKE.b

./bin/ZUMBLDMAKE: jBC_Makefile]MOBJECT/ZUMBLDMAKE.o
	CATALOG -o./bin jBC_Makefile ZUMBLDMAKE.b

jBC_Makefile]MOBJECT/ZUMGETCATS.o: jBC_Makefile/ZUMGETCATS.b
	BASIC jBC_Makefile ZUMGETCATS.b

./bin/ZUMGETCATS: jBC_Makefile]MOBJECT/ZUMGETCATS.o
	CATALOG -o./bin jBC_Makefile ZUMGETCATS.b

jBC_Makefile]MOBJECT/fnPARSESOURCE.o: jBC_Makefile/fnPARSESOURCE.b
	BASIC jBC_Makefile fnPARSESOURCE.b

libs1: $(libobj1)
	$(catlib)

lib/lib.el: $(libobj1)
	make libs1


rebuild: $(libobjs) $(binobjs)
	CATALOG -o./bin Utilities CONVBP2DIR.b ZUMBASIC.b ZUMBASICFAILS.b ZUMCATALOG.b ZUMCATEXEC.b ZUMCHECKBAS.b ZUMCREATEDIRS.b
	CATALOG -o./bin jBC_Makefile ZUMBLDMAKE.b ZUMGETCATS.b

clean:
	-rm ./lib/lib*.*
	-rm ./Functions]MOBJECT/*
	-rm ./Utilities]MOBJECT/*
	-rm ./jBC_Makefile]MOBJECT/*
