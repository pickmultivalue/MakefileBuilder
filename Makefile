libobjs=Functions]MOBJECT/fnCONVBP2DIR.o Functions]MOBJECT/fnDECODE.o Functions]MOBJECT/fnGETCATS.o Functions]MOBJECT/fnGETRELPATH.o Functions]MOBJECT/fnGETYN.o Functions]MOBJECT/fnLAST.o Functions]MOBJECT/fnMOVEOBJECT.o Functions]MOBJECT/fnOPEN.o Functions]MOBJECT/fnTRIMLAST.o jBC_Makefile]MOBJECT/fnPARSESOURCE.o
binobjs=Utilities]MOBJECT/CONVBP2DIR.o Utilities]MOBJECT/ZUMBASIC.o Utilities]MOBJECT/ZUMCATALOG.o Utilities]MOBJECT/ZUMCATEXEC.o jBC_Makefile]MOBJECT/ZUMBLDMAKE.o jBC_Makefile]MOBJECT/ZUMGETCATS.o

alltargets=./bin/CONVBP2DIR ./bin/ZUMBASIC ./bin/ZUMCATALOG ./bin/ZUMCATEXEC ./bin/ZUMBLDMAKE ./bin/ZUMGETCATS

targets: $(alltargets) lib/lib.el
define catlib
echo "" $(foreach fname,$(?),&& CATALOG -L./lib $(firstword $(subst /, ,$(fname))) $(word 2,$(subst /, ,$(fname))))
endef

all: targets

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

Utilities]MOBJECT/ZUMCATALOG.o: Utilities/ZUMCATALOG.b
	BASIC Utilities ZUMCATALOG.b

./bin/ZUMCATALOG: Utilities]MOBJECT/ZUMCATALOG.o
	CATALOG -o./bin Utilities ZUMCATALOG.b

Utilities]MOBJECT/ZUMCATEXEC.o: Utilities/ZUMCATEXEC.b
	BASIC Utilities ZUMCATEXEC.b

./bin/ZUMCATEXEC: Utilities]MOBJECT/ZUMCATEXEC.o
	CATALOG -o./bin Utilities ZUMCATEXEC.b

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

lib/lib.el: 
	make subset1 subset2

subset1: Functions]MOBJECT/fnCONVBP2DIR.o Functions]MOBJECT/fnDECODE.o Functions]MOBJECT/fnGETCATS.o Functions]MOBJECT/fnGETRELPATH.o Functions]MOBJECT/fnGETYN.o Functions]MOBJECT/fnLAST.o Functions]MOBJECT/fnMOVEOBJECT.o Functions]MOBJECT/fnOPEN.o Functions]MOBJECT/fnTRIMLAST.o 
	$(catlib)
	
subset2: jBC_Makefile]MOBJECT/fnPARSESOURCE.o
	$(catlib)

rebuild: $(libobjs) $(binobjs)
	CATALOG -L./lib -o./bin Functions fnCONVBP2DIR fnDECODE fnGETCATS fnGETRELPATH fnGETYN fnLAST fnMOVEOBJECT fnOPEN fnTRIMLAST
	CATALOG -L./lib -o./bin Utilities CONVBP2DIR ZUMBASIC ZUMCATALOG ZUMCATEXEC
	CATALOG -L./lib -o./bin jBC_Makefile ZUMBLDMAKE ZUMGETCATS fnPARSESOURCE

clean:
	-rm ./lib/lib*.*
	-rm ./Functions]MOBJECT/*
	-rm ./Utilities]MOBJECT/*
	-rm ./jBC_Makefile]MOBJECT/*
