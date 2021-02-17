# jBASE Makefile Builder

> ZUMBLDMAKE is a utility that will build a Makefile
> for BASIC code including dependencies for INCLUDEs (recursive)

> Note: Makefiles are dependent on individual source file
> changes. As such, the "BP" and "INCLUDE" files must be
> directories. Such files will be converted to directories if
> not already.

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
5. Run ZUMBLDMAKE
