libobjs=Functions]MOBJECT/fnCONVBP2DIR.o Functions]MOBJECT/fnDECODE.o Functions]MOBJECT/fnGETRELPATH.o Functions]MOBJECT/fnGETYN.o Functions]MOBJECT/fnLAST.o Functions]MOBJECT/fnMOVEOBJECT.o Functions]MOBJECT/fnOPEN.o Functions]MOBJECT/fnTRIMLAST.o jBC_Makefile]MOBJECT/fnPARSESOURCE.o
binobjs=Utilities]MOBJECT/CONVBP2DIR.o jBC_Makefile]MOBJECT/ZUMBLDMAKE.o jBC_Makefile]MOBJECT/ZUMGETCATS.o

alltargets=bin/CONVBP2DIR bin/ZUMBLDMAKE bin/ZUMGETCATS

targets: $(alltargets) lib/lib.el
define catlib
echo "" $(foreach fname,$(?),&& CATALOG -L./lib $(firstword $(subst /, ,$(fname))) $(word 2,$(subst /, ,$(fname))))
endef

all: targets

Functions]MOBJECT/fnCONVBP2DIR.o: Functions/fnCONVBP2DIR.b
	BASIC Functions fnCONVBP2DIR.b

Functions]MOBJECT/fnDECODE.o: Functions/fnDECODE.b
	BASIC Functions fnDECODE.b

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

bin/CONVBP2DIR: Utilities]MOBJECT/CONVBP2DIR.o
	CATALOG -o./bin Utilities CONVBP2DIR.b


jBC_Makefile]MOBJECT/ZUMBLDMAKE.o: jBC_Makefile/ZUMBLDMAKE.b
	BASIC jBC_Makefile ZUMBLDMAKE.b

bin/ZUMBLDMAKE: jBC_Makefile]MOBJECT/ZUMBLDMAKE.o
	CATALOG -o./bin jBC_Makefile ZUMBLDMAKE.b

jBC_Makefile]MOBJECT/ZUMGETCATS.o: jBC_Makefile/ZUMGETCATS.b
	BASIC jBC_Makefile ZUMGETCATS.b

bin/ZUMGETCATS: jBC_Makefile]MOBJECT/ZUMGETCATS.o
	CATALOG -o./bin jBC_Makefile ZUMGETCATS.b

jBC_Makefile]MOBJECT/fnPARSESOURCE.o: jBC_Makefile/fnPARSESOURCE.b
	BASIC jBC_Makefile fnPARSESOURCE.b

lib/lib.el: Functions]MOBJECT/fnCONVBP2DIR.o Functions]MOBJECT/fnDECODE.o Functions]MOBJECT/fnGETRELPATH.o Functions]MOBJECT/fnGETYN.o Functions]MOBJECT/fnLAST.o Functions]MOBJECT/fnMOVEOBJECT.o Functions]MOBJECT/fnOPEN.o Functions]MOBJECT/fnTRIMLAST.o jBC_Makefile]MOBJECT/fnPARSESOURCE.o
	$(catlib)

rebuild: $(libobjs) $(binobjs)
	CATALOG -L./lib -o./bin Functions fnCONVBP2DIR fnDECODE fnGETRELPATH fnGETYN fnLAST fnMOVEOBJECT fnOPEN fnTRIMLAST
	CATALOG -L./lib -o./bin Utilities CONVBP2DIR
	CATALOG -L./lib -o./bin jBC_Makefile ZUMBLDMAKE ZUMGETCATS fnPARSESOURCE

clean:
	-rm /Q ./lib/lib*.*
	-rm ./Functions]MOBJECT/*
	-rm ./Utilities]MOBJECT/*
	-rm ./jBC_Makefile]MOBJECT/*
