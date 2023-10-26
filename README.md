# jBASE Makefile Builder

> JUTIL_BLDMAKE is a utility that will build a Makefile
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

additionally JUTIL_BLDMAKE has an option to automatically do this (see below).

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
5. set JUTLMAKEBINS and JUTLMAKELIBS to the project's bin and lib path
(So as to restrict the bin/lib discovery to only the project and not what is in the full PATH/JBCOBJECTLIST) 
6. Run JUTIL_BLDMAKE (with appopriate options)

```
Syntax: JUTIL_BLDMAKE {-options}

Where options:

-[?,h,H] help/syntax
-v Verbose
-f<makefilename> (default: Makefile)
-o Overwrite
-m Ignore missing errors
-s Build new catalog metadata
-C Convert BP files (convert to dir, create OBJECT directory if missing)
```

## Additional utilities
| Program | Description |
|---------|-------------|
| JUTIL_GETCATS | Discovers cataloged programs/subroutines (called by JUTIL_BLDMAKE -s) |
| JUTIL_BASIC | Compiles all code discovered by JUTIL_CATS |
| JUTIL_CATALOG | Catalogs all code discovered by JUTIL_CATS |
| JUTIL_CHECKBAS | Checks if the code is compiled (including checking if the object is newer than the source) |
| CONVBP2DIR | Converts a BP hashed file to a DIR type and creates a BP,OBJECT director if applicable |

### JUTIL_GETCATS
This utility generates **JUTLCATS** and **JUTLLIBS** and additionally writes out two files to the current directory:

1. executes_found
2. subroutines_found

These two files are not meant to be definitive discoveries of programs and subroutines EXECUTEd or CALLed but can be useful for getting an overview of what is *in use*. The only entries written out are those that are quoted (for EXECUTE) or not @subname (in the case of CALL).

### JUTIL_BASIC
As well as compiling the source it populates a BASICFAILS file/directory with any failures.
