libobjs=Functions]MOBJECT/fnDECODE.o Functions]MOBJECT/fnCONVBP2DIR.o Functions]MOBJECT/fnMOVEOBJECT.o Functions]MOBJECT/fnLAST.o Functions]MOBJECT/fnTRIMLAST.o Functions]MOBJECT/fnOPEN.o Functions]MOBJECT/fnGETYN.o Functions]MOBJECT/fnGETRELPATH.o jBC_Makefile]MOBJECT/fnPARSESOURCE.o
binobjs=jBC_Makefile]MOBJECT/ZUMBLDMAKE.o jBC_Makefile]MOBJECT/ZUMGETCATS.o Utilities]MOBJECT/CONVBP2DIR.o
alltargets=bin/ZUMBLDMAKE bin/ZUMGETCATS bin/CONVBP2DIR

define catlib
echo "" $(foreach fname,$(?),&& CATALOG -L./lib $(firstword $(subst /, ,$(fname))) $(word 2,$(subst /, ,$(fname))))
endef

targets: $(alltargets) lib/lib.el

all: targets

Functions]MOBJECT/fnDECODE.o: Functions/fnDECODE.b
	BASIC Functions fnDECODE.b

Functions]MOBJECT/fnCONVBP2DIR.o: Functions/fnCONVBP2DIR.b
	BASIC Functions fnCONVBP2DIR.b

Functions]MOBJECT/fnMOVEOBJECT.o: Functions/fnMOVEOBJECT.b
	BASIC Functions fnMOVEOBJECT.b

Functions]MOBJECT/fnLAST.o: Functions/fnLAST.b
	BASIC Functions fnLAST.b

Functions]MOBJECT/fnTRIMLAST.o: Functions/fnTRIMLAST.b
	BASIC Functions fnTRIMLAST.b

Functions]MOBJECT/fnOPEN.o: Functions/fnOPEN.b
	BASIC Functions fnOPEN.b

Functions]MOBJECT/fnGETYN.o: Functions/fnGETYN.b
	BASIC Functions fnGETYN.b

Functions]MOBJECT/fnGETRELPATH.o: Functions/fnGETRELPATH.b
	BASIC Functions fnGETRELPATH.b

jBC_Makefile]MOBJECT/ZUMBLDMAKE.o: jBC_Makefile/ZUMBLDMAKE.b
	BASIC jBC_Makefile ZUMBLDMAKE.b

bin/ZUMBLDMAKE: jBC_Makefile]MOBJECT/ZUMBLDMAKE.o
	CATALOG -o./bin jBC_Makefile ZUMBLDMAKE.b

jBC_Makefile]MOBJECT/fnPARSESOURCE.o: jBC_Makefile/fnPARSESOURCE.b
	BASIC jBC_Makefile fnPARSESOURCE.b

jBC_Makefile]MOBJECT/ZUMGETCATS.o: jBC_Makefile/ZUMGETCATS.b
	BASIC jBC_Makefile ZUMGETCATS.b

bin/ZUMGETCATS: jBC_Makefile]MOBJECT/ZUMGETCATS.o
	CATALOG -o./bin jBC_Makefile ZUMGETCATS.b

Utilities]MOBJECT/CONVBP2DIR.o: Utilities/CONVBP2DIR.b
	BASIC Utilities CONVBP2DIR.b

bin/CONVBP2DIR: Utilities]MOBJECT/CONVBP2DIR.o
	CATALOG -o./bin Utilities CONVBP2DIR.b

lib/lib.el: Functions]MOBJECT/fnDECODE.o Functions]MOBJECT/fnCONVBP2DIR.o Functions]MOBJECT/fnMOVEOBJECT.o Functions]MOBJECT/fnLAST.o Functions]MOBJECT/fnTRIMLAST.o Functions]MOBJECT/fnOPEN.o Functions]MOBJECT/fnGETYN.o Functions]MOBJECT/fnGETRELPATH.o jBC_Makefile]MOBJECT/fnPARSESOURCE.o
	$(catlib)

clean:
	rm $(libobjs)
	rm $(binobjs)
