# jBASE Utilities
This section is for singleton utility programs
(i.e. executable programs with no dependencies).


## move2enc.b
move2enc relocates jBASE files to another directory
(i.e. typically an encrypted partition).

Upon moving the original file a symbolic link is created
in the original location so that applications still access
the file in the expected location.

Syntax: move2enc [-d<enc_dir>] [-v] [-p] [-t] [-?,h,H] <filename>
where: d - destination
       m - create MD (and SYSTEM)
       p - prompt
       t - test mode
       v - verbose
     ?|h - syntax
       H - full help

This command moves a file from its normal location
to an encrypted disk.

(e.g. mv /dbms/<acc>/<filename> -> /dbms/encrypted/<acc>/<filename>.

A SYSTEM entry and Q pointer will also
be created to point to the new file location
as well as a softlink.
