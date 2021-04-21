# jBASE Makefile Builder

> ZUMBLDMAKE is a utility that will build a Makefile
> for BASIC code including dependencies for INCLUDEs (recursive)

> Note: Makefiles are dependent on individual source file
> changes. As such, the "BP" and "INCLUDE" files must be
> directories. Such files will be converted to directories if
> not already.

## Benefits of using a Makefile in your jBASE Application
Most *PICK* applications use INCLUDE statements for storing common logic. 
Often these include definitions for record structures, COMMON blocks.

If any one of these includes change you would typically want to recompile all programs that use these includes.

This is where the Makefile Builder comes in. Using an existing application environment it *discovers* the INCLUDE statements used in the cataloged programs and subroutines and builds a Makefile with dependencies that recognise if an INCLUDE is changed the Makefile will *know* which programs need recompiling/cataloging.

## Preparation
The Makefile Builder requires the a **,OBJECT** data level for all *BP* files.
```
e.g. BP]MOBJECT
```
and that both the *BP* file and *OBJECT* be directories.
A utility is provided to do that for you:

**CONVBP2DIR *BP_file***

additionally ZUMBLDMAKE has an option to automatically do this (see below).

## Installation/Setup
>You will need access to GNU make of non-Windows or nmake.exe for Windows.

Run **make** to build the project.

This will generate bins and libs which you will need to add to your
PATH and JBCOBJECTLIST respectively so that you can build your Makefiles.

## Instructions/Usage

1. Change directory to the top tree where "BP" source files are located.
2. Create bin/lib directories if not already in existence.
(You may need to clear these for a clean Makefile result...see step 3.)
3. If you cleaned out your local bin/lib directories: BASIC/CATALOG all source to the local bin/lib
4. Set PATH and JBCOBJECTLIST such that these local bin/lib will
correctly detect the cataloged programs. (this may already be the case for an existing project)
5. Run ZUMBLDMAKE (with appopriate options)

```
Syntax: ZUMBLDMAKE {-options}

Where options:

-[?,h,H] help/syntax
-v Verbose
-f<makefilename> (default: Makefile)
-o Overwrite
-m Ignore missing errors
-C Convert BP files (convert to dir, create OBJECT directory if missing)
```

## Additional utilities
| Program | Description |
|---------|-------------|
| ZUMGETCATS | Discovers cataloged programs/subroutines (called by ZUMBLDMAKE -s) |
| ZUMBASIC | Compiles all code discovered by ZUMCATS |
| ZUMCATALOG | Catalogs all code discovered by ZUMCATS |
| ZUMCHECKBAS | Checks if the code is compiled (including checking if the object is newer than the source) |
| CONVBP2DIR | Converts a BP hashed file to a DIR type and creates a BP,OBJECT director if applicable |


|
