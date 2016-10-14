#!/usr/local/bin/perl -w
# $Id: hdfgen.pl,v 1.47 1998/07/28 00:22:51 steves Exp $

######################################################################
# hdfgen.pl is a perl script that converts a C structure into C code.

# The C code is in the form of functions that will initialize, read and
# write Hierarchical Data Format (HDF) files.

# Its use: allow minimal knowledge of HDF read and write code by the user.

#######################################################################
# hdfgen.pl uses at least 2 command line ARGUMENTS, 
#   with optional ARGUMENTS 3, 4 and/or 5.
#
# The 1st ARGUMENT is the input file
#	and is in the form of a single C structure in a .h file.
#
# The 2nd ARGUMENT is the name of the output file (.c)
#
# The 'F=' ARGUMENT (opitional) is added to the function name given to
#	the created functions (this will create unique functions).
#   Leaving off the 'F=' ARGUMENT defaults to using the input filename
#	(the 1st ARGUMENT) minus the .h as part of the function names.
#	This also preserves uniqueness.
#
# The 'I=' ARGUMENT (opitional) is a list of filenames that contain #define 
#	statements that the current input_file uses.
#	The list is comma delimited.
#
# The 'N=' ARGUMENT (opitional) is added to the variable and Vgroup names
#       in order to create unique names.
#   Leaving off the 'N=' ARGUMENT defaults to using the structure name
#	from the input file.
#	This should also preserve uniqueness.
#
# Example:
#   note- parentheses denote optional arguments
#
#	use hskp.h to create hskp.c
# hdfgen.pl hskp.h hskp.c (F=test_func) (I=tst1.h,tst2.h,tst3.h) (N=hskp_name)
#	or in more generic terms:
# hdfgen.pl in_file out_file (F=partial_func_name) (I=file1,file2) (N=name)

#!each variable in the structure must be declared on an individual line!#
#########################################################################

###################### ONE DIMENSIONAL ARRAY VALUE ######################
# 1 dimensional arrays with a number of elements that are greater than
# $MAX_ELEMENTS_FOR_VDATA are made into SD data. while those less than or
# equal to $MAX_ELEMENTS_FOR_VDATA are made into V data.
# Array[X]   is SDS if X > $MAX_ELEMENTS_FOR_VDATA
#            is Vdata if X <= $MAX_ELEMENTS_FOR_VDATA
# This is done because Vdata's in HDF4.1r1 have a limited size (64k).

		     $MAX_ELEMENTS_FOR_VDATA = 5000;
#########################################################################
	#get command line ARGUMENTS
$input_file = $ARGV[0];
$output_file = $ARGV[1];

	#check to see if the input file and output file are equal
$ARGV[0] eq $ARGV[1] && die "Error: input file '$input_file' equals output file '$output_file'\n";

$inc_file = $input_file;
	#get $input_file without leading directory names
@parts = split(/\//, $input_file);
$filename = pop(@parts);

	#get $output_file without leading directory names
@parts = split(/\//, $output_file);
$out_file = pop(@parts);

$func_name_chk = 0;
$part_name_chk = 0;

	#3, 4 or 5 arguments? then look for 'F=', 'I=' and 'N='
if($#ARGV == 2 || $#ARGV == 3 || $#ARGV == 4){
  for ($ii=2; $ii<=$#ARGV; $ii++){
    if ( $ARGV[$ii] =~ /^F=/i ){
      $func_name_chk = 1;
	#set $func_name to string after 'F='
      $func_name = $ARGV[$ii];
      $func_name =~ s/^F=//i;
	#no arguments start with 'F=', 
	# set $func_name to $input_file - the .h (see below)

    }elsif ( $ARGV[$ii] =~ /^I=/i ){
      $include_list = $ARGV[$ii];
      $include_list =~ s/^I=//i;
      @include_names = split(/,/,$include_list);

    }elsif ( $ARGV[$ii] =~ /^N=/i ){
      $part_name_chk = 1;
	#set $part_name to string after 'N='
      $part_name = $ARGV[$ii];
      $part_name =~ s/^N=//i;
	#no arguments start with 'N=', 
	# set $part_name to $Struct_Name (see below)
    }else{
		#give help for proper use of arguments
      warn "\nError: '$ARGV[$ii]' must begin with an 'F=', 'I=' or 'N='.\n";

      warn "\n    F=  proceeds the 'Function name' argument. It is added to create unique function\n     names (the default is the input file '$filename' minus the .h).\n     Example: hdfgen.pl foo.h foo.c F=partial_function_name\n";

      warn "\n    I=  proceeds the 'Include' argument list. It is added so that hdfgen.pl can\n     find all \#define statements related to the current input file. \n     (the list is comma delimited).\n     The current input file '$filename' is always checked for \#define's.\n     Example of use:\n\t hdfgen.pl foo.h foo.c I=test1.h,test2.h,test3.h\n";

      warn "\n    N=  proceeds the 'partial name' argument. It is added to create unique variable\n     names (the default is the structure name).\n     Example: hdfgen.pl foo.h foo.c N=partial_variable_name\n";

      die "\n  None, one or all of these arguments may be used and in any order. \n   Example: hdfgen.pl foo.h foo.c F=partial_function_name I=test1.h,test2.h N=partial_variable_name\n\n";
    }
  }#end for loop
}elsif ($#ARGV != 1){
  die "Error: hdfgen.pl uses 2, 3, 4 or 5 arguments.\n";
}

	#functin name not given any arguments, use default (input filename -.h)
if ( $func_name_chk != 1 ){
  $func_name = $filename;
  $func_name =~ s/.h$//;
}
#($instr_name) = split(/_/, $func_name);
#print"\ninstr name       $instr_name \n\n";

	#open the file(s) given in the 'I=' argument list and find constants
foreach (@include_names){
  open (CONSTANTS,"$_") || warn "WARNING: can't open constant definition file: $_";
	#find constants
  while (defined($const_line = <CONSTANTS>)){
	#find lines that contain #define in them
    if ($const_line =~ /^#define\s+(\w+)\s+(.+)\s*\n/){
	#check for different definition of same constant
      foreach $key (keys %define){
        if ( $key eq $1 && $define{$key} ne $2 ){
          warn"WARNING: $1 has multiple definitions. this one is in file $_";
          warn "         it's current value is:  $2\n";
        }
      }#end foreach loop
	#put into an associative array
    $define{$1} = $2;
#print"$1       $2\n";
    }
  }#end while loop
close (CONSTANTS);
}#end foreach loop

	#setup include file.  
	#This assumes that -I option is being used by the compiler
	#If not, then comment out the following line
$inc_file = $filename;

	#open .h file
open (IN,"$input_file") || die "ERROR: can't open input file '$input_file'";

	#open the output file
open (OUT,">$output_file") || die "can't create output file '$output_file'";

	#initialize variables 
$total_size=$V_index=$SD_index=$maxdim=$rank=$variable_counter=$num_elements=0;
$_="";

$vgrp_class = $filename;
	#remove ending .h from $vgrp_class
$vgrp_class =~ s/\.h$//;
	#change $vgrp_class to all capitals
$vgrp_class =~ tr/a-z/A-Z/;


	#get RCS (Revision Control System) header for hdfgen.pl and the
	# include file and put in created file
print OUT"/* The RCS version of hdfgen.pl used to create this file is: */\n";
print OUT"/* \$Id: hdfgen.pl,v 1.47 1998/07/28 00:22:51 steves Exp $_ */\n";

######################### begin work on file #########################
	#get first line
$line = <IN>;

	#find RCS header in the include file
if ($line =~ /\$(Id:[^\$]+)/)
{
  print OUT"\n/* The include file used to create this file is: */\n";
  print OUT"/* \$$1 */\n\n";
}elsif ($line =~ /^\s*struct/){
  die "In '$input_file' structure must start on line 2 or greater for proper processing.\n";
}else{
  warn "Alert: An RCS header for input file '$filename' not on first line.\n";
  print OUT"\n  /* An RCS (Revision Control System) header */\n";
  print OUT"\n  /* for the include file is not on the first line. */\n\n";
}
#########begin main while loop###########

	#read in each line from $input_file using the filehandle IN
while ( defined($line = <IN>)) {
	#end of structure? yes, get out of while loop
  if ($line =~ /.*};/){
	#empty structure? yes. 
    if ($variable_counter == 0){
      print"Warning: Empty structure '$Struct_Name' in '$input_file'. Process? (y/n) ";
	#continue reading? no. die
      if (<STDIN> =~ /^n/i) {
        print OUT"\nStructure $Struct_Name NOT Processed! \n";
        die "In '$input_file', $Struct_Name not processed\n";
      }
    }
    last;
  }

	#line contains a comment marker (/*) or (//)? yes, remove comment
  if ($line =~ m!.*/\*!){
    $line =~ s/\/\*.*\*\/// || die "In file '$input_file' on line:\n$line
    Beginning (/*) and ending (*/) comment markers must be on the same line for
    correct processing of file.\n";
	#check for c++ comment markers (//)
  }elsif ($line =~ m!.*//!){
    $line =~ s/\/\/.*//;
  }

	#check for more than ONE statement per line
  $line =~ /;.*;/ && die "Problem on line:\n $line in file '$input_file'\n Only able to process ONE statement per line (only one ';' per line).\n";

	#check for more than ONE declaration per line
  $line =~ /,/ && die "Problem on line:\n $line in file '$input_file'\n Only able to process ONE declaration per line (no commas).\n";

	#get max length of lines
#  if (length($line) > $maxline_length){
#    $maxline_length = length($line);
#  }
	#find constants
  if ($line =~ /^#define\s+(\w+)\s+(.+)\s*\n/){
    foreach $key (keys %define){
      if ( $key eq $1 && $define{$key} ne $2 ){
        warn"WARNING: $1 has multiple definitions. this one in '$input_file'\n";
        warn "         it's current value is:  $2\n";
      }
    }#end foreach loop
	#put into an associative array
    $define{$1} = $2;
  }
  	#find the name of the struct
  if ( $line =~ /struct\s/){
    $structure = $line;
#print"$structure\n";
	#remove space 
    $structure =~ s/\s*struct\s+/struct/;
    $structure =~ s/\s+.+//;
	#remove '{'
    $structure =~ s/{//;
	#add a space after 'struct'
    $structure =~ s/struct/struct /;
	#remove newline character
    chop($structure);
    $Struct_Name = $structure;
	#remove 'struct '
    $Struct_Name =~ s/struct //;
    if ( $part_name_chk != 1 ){
      $part_name = $Struct_Name;
    }
  }
	#line contains a variable because it has ";" or is it to short?
    if ( $line =~ /;/ && length($line) > 7){
      $variable_counter++;
      $declaration = $line;
	#remove ';' and anything after it
      $declaration =~ s/;.*//;
    	#remove wht space from beginning
      $declaration =~ s/^\s+//;
    	#replace first wht space with ':' to be used for parsing
      $declaration =~ s/\s+/:/;
    	#remove all possible wht space between name and last ']'
      $declaration =~ s/\s+//g;
#print"$declaration\n";
    	#split the declaration at ':'. get the variable name and it's type
      ($type, $var_name) = split(/:/,$declaration);
#print"$type   $var_name \n";

	#convert elements for 1 dimensional arrays into numeric values.
	#depending on the number of elements make into SD data or V data.

	#get all arrays 
      if ($var_name =~ /\[.*\]/ ){
		#weed out arrays with more than 1 dimension 
        if (!($var_name =~ /\]\[/ )){
          (@var_name_components) = split(/\[/, $var_name);
		#remove trailing ']'
          chop(@var_name_components);
		#get number of elements in the array
          $num_elements = $var_name_components[1];
		#check for non digit
		#(check for constants that refer to other constants)
          while ($num_elements =~ /[a-zA-Z_]/){
            $num_elements_noparens = $num_elements;
		#remove parenthesis if there are any
            $num_elements_noparens =~ s/\(?\)?//g;
		#split using *, /, -, and/or +
            (@constant1) = split(/[\*\/\+-]/, $num_elements_noparens);
		#look at each element in constant1
            foreach $sub_element (@constant1){
		#check for non digit
              if ($sub_element =~ /[a-zA-Z_]/){
			#was this constant name found earlier in this program
                if (!($define{$sub_element})){
                  warn "Error: In input_file '$input_file' can't find value for constant: $sub_element\n";
                  die "\n I=  proceeds the 'Include' argument list. It is added so that hdfgen.pl can\n     find all \#define statements related to the current input file. \n     (the list is comma delimited).\n     The current input file '$filename' is always checked for \#define's.\n     Example of use:\n\t hdfgen.pl foo.h foo.c I=test1.h,test2.h,test3.h\n";
                }
			#replace constant name with it's defined value
			# defined values determined earlier in this program
                $num_elements =~ s/$sub_element/$define{$sub_element}/;
              }else{
			#contains only digits and operators, evaluate it
                $ev_sub_element = eval($sub_element);
			#replace non-evaluated string with evaluated string
                $num_elements =~ s/$sub_element/$ev_sub_element/;
              }
            }#end foreach loop
          }##end while loop
          $num_elements = eval($num_elements);
          $mod1 = $num_elements % ($num_elements + 1);
          $mod1 = $num_elements - $mod1;
          $mod1 == 0 || die "ERROR: $var_name_components[1] evaluated to $num_elements  a non-integer! In file: $input_file\n";
        } 
      }
	#determine if the array has more than 1 dimension
	# or it is very large
#print"SDSDSDSDSDSDSD $num_elements\n";
      if ($var_name =~ /\]\[/ || $num_elements > $MAX_ELEMENTS_FOR_VDATA){
#print"SDSDSDSDSDSDSD $var_name\n";
        $arrays[$SD_index] = $var_name;
		#split it into it's name and parameters
        @fields = split(/\[\s*/,$arrays[$SD_index]);
        if ($#fields > $maxdim) {
          $maxdim = $#fields;
		#to set the SD arrays to their proper length add 1
	  $maxdimplus1 = $maxdim + 1;
        }
		#get the name of the SD array
        $SD_name[$SD_index] = $fields[0];
		#remove the ending "]" of the dimensional values
        chop(@fields);
		#put number of dimensions in 0 element
        $dim[$SD_index][0] = $#fields;
		#put dimension values in 1st, 2nd, 3rd ... element
        for ($cc=1; $cc<=$#fields; $cc++) {
          $dim[$SD_index][$cc] = $fields[$cc];
        }
    		#get the array type
        $SD_Type[$SD_index] = $type;
    		#change array type to UPPERCASE for later use
        $SD_Type[$SD_index] =~ tr/a-z/A-Z/;
        $SD_index++;
      }else {	#split the name at the first '['
#print"VVVVVVVVVVVVVVVVV $var_name\n";
        ($V_name[$V_index], $V_dim[$V_index]) = split(/\[/, $var_name);
		#if no $V_dim then the variable has 1 element
        if (!($V_dim[$V_index])){
          $V_dim[$V_index] = 1;
        }
		#get rid of ending "]"
        $V_dim[$V_index] =~ s/\]//;

    		#get the variable type
        $V_Type[$V_index] = $type;
    		#change variable type to UPPERCASE for later use
        $V_Type[$V_index] =~ tr/a-z/A-Z/;

    		#determine variable byte size: multiply the base byte size
		# by the number of elements in the variable
        $V_base[$V_index] = $V_Type[$V_index];
        $V_base[$V_index] =~ s/int//i;
        $V_base[$V_index] =~ s/u//i;
        $V_base[$V_index] =~ s/float//i;
        $V_base[$V_index] =~ s/char//i;
		#check the Vdata size to make sure it's not to large
        &size_chk_of_Vdata($num_elements, $V_base[$V_index]);
#print"num elem x base ($num_elements * $V_base[$V_index])  $V_dim[$V_index]\n";
        ($V_base[$V_index] /= 8) || die "Problem on line in '$input_file': \n$line can't use: '$type' in '$structure', must explicitly state bit length. Such as: int16 variable_name. (see hdfi.h)\n";

        $V_index++;
      }
    }
    $num_elements = 0;
} #############end of main while loop##################
#print "numvars = $variable_counter\t$vgrp_class\n";
print"Vdata total size = $total_size bytes\n";

	#structure ended with "};"? no! give warning
($line =~ /.*};/) || die "In input file '$input_file', structure '$structure' must end with a '};'.\n";

############ BEGIN OUTPUT TO FILE ############
	#output: the header files
print OUT"#include \"$inc_file\"\n";
	#does the structure contain SD data
$SD_index > 0 && print OUT"#include \"mfhdf.h\"\n";

print OUT"#include \"df.h\"\n\n";
print OUT"int32 vgrp_id_$func_name;\n";
	#does the structure contain V data 
print OUT"static int32 vdata_id_$func_name;\n";

	#does the structure contain SD data
if ($SD_index > 0) {
  print OUT"\nstatic int32 ";
  for ($cc=1; $cc<$SD_index; $cc++){
    print OUT"sds_id_$func_name"."$cc, ";
  }
  print OUT"sds_id_$func_name"."$cc;\n";
}
	#get size of 'input_file' + the extra line added 
	# to the beginning of the description
$infile_size = (-s $input_file) + 200;
print OUT"\n  /* $infile_size is the size of $filename + 1 added line */\n";
print OUT"char Vgrp_descrp_$part_name"."[$infile_size];\n";

############output: init create function############

print OUT"\n/****----  init create function  ----****/\n\n";

print OUT"int32 init_cr_$func_name";
print OUT"(int32 hdf_fp, int32 sd_id, int32 an_id, char *classname)\n{\n";
print OUT"  int32 retval=0;\n";
print OUT"  int32 vgrp_ref_w;\n";
print OUT"  int32 ann_id_w;\n";
	#does the structure contain SD data
if ($SD_index > 0) {
  print OUT"\n  int32 ";
  for ($cc=1; $cc<$SD_index; $cc++){
    print OUT"sds_ref_w$cc, ";
  }
  print OUT"sds_ref_w$cc;\n";
  print OUT"  int32 dim_sizes\[$maxdimplus1\];\n";
  print OUT"  int32 rank;\n\n";
}
print OUT"  int32 wr_Vgrp_desc_$func_name();\n\n";

print OUT"  void print_$func_name"."_error();\n\n";

	#setup a Vgroup
print OUT"  /*         Setup a Vgroup         */\n";
print OUT"  if ((vgrp_id_$func_name = Vattach(hdf_fp, -1, \"w\"))==FAIL) {\n";
print OUT"    print_$func_name"."_error(\"init_cr_$func_name -> Vattach: Couldn't create Vgroup\");\n";
print OUT"    retval = -1;\n  }\n";
print OUT"  Vsetname(vgrp_id_$func_name, \"VG_$part_name\"); \n";
print OUT"  Vsetclass(vgrp_id_$func_name, \"VG_$vgrp_class\");\n\n";

print OUT"\n  /*      Get the Vgroup reference     */\n";
print OUT"  if ((vgrp_ref_w = Vfind(hdf_fp, \"VG_$part_name\" )) ==FAIL) {\n";
print OUT"    print_$func_name"."_error(\"init_cr_$func_name -> Vfind: Couldn't get Vgrp reference\");\n";
print OUT"    retval = -1;\n  }\n";

print OUT"  /*      Add a description to the Vgroup      */\n";

print OUT"  wr_Vgrp_desc_$func_name(Vgrp_descrp_$part_name);\n\n";

print OUT"  if ((ann_id_w = ANcreate(an_id, DFTAG_VG, vgrp_ref_w, AN_DATA_DESC)) ==FAIL) {\n";
print OUT"    print_$func_name"."_error(\"init_cr_$func_name -> ANcreate: Can't create Vgrp description\");\n";
print OUT"    retval = -1;\n  }\n";


print OUT"  if ((ANwriteann(ann_id_w, Vgrp_descrp_$part_name, sizeof(Vgrp_descrp_$part_name))) ==FAIL) {\n";
print OUT"    print_$func_name"."_error(\"init_cr_$func_name -> ANwriteann: Can't write Vgrp description\");\n";
print OUT"    retval = -1;\n  }\n";

print OUT"  ANendaccess(ann_id_w);\n\n";

	#does the structure contain Vdata
if ($V_index > 0) {
  print OUT"  /*        Setup a Vdata        */\n";
  print OUT"  if ((vdata_id_$func_name = VSattach(hdf_fp, -1, \"w\")) ==FAIL) {\n";
  print OUT"    print_$func_name"."_error(\"init_cr_$func_name -> VSattach: Couldn't attach to Vdata\");\n";
  print OUT"    retval = -1;\n  }\n";
  print OUT"  VSsetname(vdata_id_$func_name, \"$part_name\");\n";
  print OUT"  VSsetclass(vdata_id_$func_name, classname);\n\n";
}
	#put the Vdata (if created) into the Vgroup
if ($V_index > 0) {
  print OUT"  /*       Insert the Vdata into the Vgroup       */\n";
  print OUT"  if ((Vinsert(vgrp_id_$func_name, vdata_id_$func_name)) ==FAIL) {\n";
  print OUT"    print_$func_name"."_error(\"init_cr_$func_name -> Vinsert: Couldn't insert Vdata into Vgroup\");\n";
  print OUT"    retval = -1;\n  }\n";
  print OUT"\n  /*    Define the fields in the Vdata    */\n";
}
	#define the fields in the Vdata
for ($cc=0; $cc<$V_index; $cc++){
  print OUT"  if (VSfdefine(vdata_id_$func_name, \"$V_name[$cc]\", ";
  print OUT"DFNT_$V_Type[$cc], ($V_dim[$cc]) )) {\n";
  print OUT"    print_$func_name"."_error(\"init_cr_$func_name -> VSfdefine: Couldn't define $V_name[$cc]\");\n";
  print OUT"    retval = -1;\n  }\n";
}
	#does the structure contain V data
if ($V_index > 0) {
  print OUT"\n  if (VSsetfields(vdata_id_$func_name,\"";
	#output: the names of the variables except the last one
  for ($cc=0; $cc<$V_index-1; $cc++){
    print OUT"$V_name[$cc], ";
  }
	#output: the last variable minus the comma
  print OUT"$V_name[$V_index-1]\")){\n";
  print OUT"    print_$func_name"."_error(\"init_cr_$func_name -> VSsetfields: Couldn't set fields\");\n";
  print OUT"    retval = -1;\n  }\n";
}
	#initialize SDS's if any
if ($SD_index > 0) { print OUT"\n /*  Create SDS's and add to the Vgroup  */";}
for ($c1=0; $c1<$SD_index; $c1++){
  $rank = ($dim[$c1][0]+1);
  print OUT"\n  rank = $rank;\n";
  print OUT"  dim_sizes\[0\] = SD_UNLIMITED;\n";
  for ($c2=1; $c2<$rank; $c2++){
    print OUT"  dim_sizes\[$c2\] = $dim[$c1][$c2];\n";
  }
  $c1plus1 = $c1 + 1;
  print OUT"  if((sds_id_$func_name"."$c1plus1 = SDcreate(sd_id, \"$part_name"."_$SD_name[$c1]\", DFNT_$SD_Type[$c1], rank, dim_sizes)) == FAIL)\n";
  print OUT"    print_$func_name"."_error(\"init_cr_$func_name -> SDcreate: Couldn't create $part_name"."_$SD_name[$c1]\");\n\n";

  print OUT"  /*  Add SDS to Vgroup  */\n";
  print OUT"  if((sds_ref_w$c1plus1 = SDidtoref(sds_id_$func_name"."$c1plus1)) == FAIL)\n";
  print OUT"    print_$func_name"."_error(\"init_cr_$func_name -> SDidtoref: Couldn't get ref for $part_name"."_$SD_name[$c1]\");\n\n";

  print OUT"  if((Vaddtagref(vgrp_id_$func_name, DFTAG_NDG, sds_ref_w$c1plus1)) == FAIL)\n";
  print OUT"    print_$func_name"."_error(\"init_cr_$func_name -> Vaddtagref: Couldn't add SDS $part_name"."_$SD_name[$c1] to Vgrp\");\n";
}
print OUT"\n  return(retval);\n}\n";

print OUT"\n/* Included for backwards compatibility */\n\n";
print OUT"int32 init_wr_$func_name";
print OUT"(int32 hdf_fp, int32 sd_id, int32 an_id, char *classname)\n{ ";
print OUT"return( init_cr_$func_name";
print OUT"(hdf_fp, sd_id, an_id, classname) ); }\n";

                   ######################
###################output: write function#####################
print OUT"\n/******---- write function ----******/\n\n";

print OUT"int32 write_$func_name($structure $part_name"."_struc, int32 recnum)\n{\n";
	#does the structure contain SD data
$SD_index > 0 &&  print OUT"  int32 start\[$maxdimplus1\], edges\[$maxdimplus1\];\n";

print OUT"  int32 retval = 0;\n  uint8 *odata;\n";
	#does the structure contain SD data
$SD_index > 0 &&  print OUT"  static int32 recnum_wr=0;\n";

print OUT"\nvoid print_$func_name"."_error();\n";

print OUT"void pack_$func_name();\n\n";
print OUT"  odata = (uint8 *) malloc(sizeof($structure));\n";
print OUT"  pack_$func_name(odata, &$part_name"."_struc);\n\n";

print OUT"  if(recnum!=-1) {\n";
$SD_index > 0 &&  print OUT"\trecnum_wr=recnum;\n";
print OUT"\tif(VSseek(vdata_id_$func_name, recnum)==-1) {\n";
print OUT"\t\tprint_$func_name"."_error(\"write_$func_name -> VSseek: error.\");\n";
print OUT"\t\tretval = -1;\n\t}\n";
print OUT"  }\n";

	#convert the input name to uppercase
	#and replace underscore with a space
  $func_name1 = $func_name;
  $func_name1 =~ tr/a-z/A-Z/;
  $func_name1 =~ tr/_/ /;
	#does the structure contain V data
if ($V_index > 0) {
  print OUT"  if(VSwrite(vdata_id_$func_name, (uint8 *)odata, 1, FULL_INTERLACE) == -1)\n";
  print OUT"    print_$func_name"."_error(\"write_$func_name -> VSwrite: Couldn't write data.\");\n\n";
}

	#does the structure contain SD data
if ($SD_index > 0) {
  print OUT"  start\[0\] = recnum_wr++;\n";
  for ($c2=1; $c2<=$maxdim; $c2++){
    print OUT"  start\[$c2\] = 0;\n";
  }
  print OUT"  edges\[0\] = 1;\n\n";
}
for ($c1=0; $c1<$SD_index; $c1++){
  $rank = ($dim[$c1][0]+1);
  for ($c2=1; $c2<$rank; $c2++){
    print OUT"  edges\[$c2\] = $dim[$c1][$c2];\n";
  }
  $c1plus1 = $c1 + 1;
  print OUT"  if (SDwritedata(sds_id_$func_name"."$c1plus1,start,NULL,edges,";
  print OUT" (VOIDP)($part_name"."_struc.$SD_name[$c1])) ==FAIL)\n";
  print OUT"    print_$func_name"."_error(\"write_$func_name -> SDwritedata: Problem writing $SD_name[$c1] data.\");\n\n";
}
print OUT"  memset(&$part_name"."_struc, 0, sizeof($structure));\n";
print OUT"  free(odata);\n  return(retval);\n}\n";

#########output: close write function
print OUT"\n/*----   close write function    ----*/\n\n";
print OUT"void close_wr_$func_name()\n{\n";
	#does the structure contain V data
$V_index > 0 &&  print OUT"  VSdetach(vdata_id_$func_name);\n";
print OUT"  Vdetach(vgrp_id_$func_name);\n";

for ($cc=1; $cc<=$SD_index; $cc++){
  print OUT"  SDendaccess(sds_id_$func_name"."$cc);\n";
}
print OUT"}\n";

############init access function###############

print OUT"\n/*----     init access function    ----*/\n\n";

print OUT"int32 init_acc_$func_name(int32 hdf_fp, int32 sd_id, char *access_mode)\n{\n";
for ($cc=1; $cc<=$SD_index; $cc++){
  print OUT"  static int32 sds_index$cc;\n";
}
	#does the structure contain V data
$V_index > 0 &&  print OUT"  int32 vdata_ref;\n";

#print OUT"  int32 retval=0;\n";
print OUT"  int32 num_rec;\n\n";
print OUT"  void print_$func_name"."_error();\n\n";

for ($c1=0; $c1<$SD_index; $c1++){
  $c1plus1 = $c1 + 1;
  print OUT"  if((sds_index$c1plus1=SDnametoindex(sd_id, \"$part_name"."_$SD_name[$c1]\" )) ==FAIL) {\n";
  print OUT"      print_$func_name"."_error(\"init_acc_$func_name -> SDnametoindex: Couldn't find $part_name"."_$SD_name[$c1]\");\n";
#  print OUT"      retval = -1;\n  }\n";
  print OUT"      return(-1);\n  }\n";

  print OUT"  if((sds_id_$func_name"."$c1plus1=SDselect(sd_id, sds_index$c1plus1)) ==FAIL) {\n";
  print OUT"      print_$func_name"."_error(\"init_acc_$func_name -> SDselect: Couldn't select sds_index$c1plus1\");\n";
#  print OUT"      retval = -1;\n  }\n";
  print OUT"      return(-1);\n  }\n";
}
	#does the structure contain V data
if ($V_index > 0) {
  print OUT"\n  if ((vdata_ref = VSfind(hdf_fp, \"$part_name\")) <= 0 ) {\n";
  print OUT"    print_$func_name"."_error(\"init_acc_$func_name -> VSfind: Found no vdata of specified type.\");\n";
  print OUT"    return(0);\n  }\n";

  print OUT"  if ((vdata_id_$func_name = VSattach(hdf_fp, vdata_ref, access_mode)) ==FAIL) {\n";
  print OUT"    print_$func_name"."_error(\"init_acc_$func_name -> VSattach: Couldn't attach to hdf file.\");\n";
  print OUT"    return(-1);\n  }\n";
}
	#check to see if Vdata has been written
print OUT"\n  VSinquire(vdata_id_$func_name, &num_rec, NULL, NULL, NULL, NULL);\n";
print OUT"  if (num_rec == 0) { return(0); }\n\n";

	#does the structure contain V data
if ($V_index > 0) {
  print OUT"\n  if (VSsetfields(vdata_id_$func_name,\"";
	#output: the names of the variables except the last one
  for ($cc=0; $cc<$V_index-1; $cc++){
    print OUT"$V_name[$cc], ";
  }
	#output: the last variable minus the comma
  print OUT"$V_name[$V_index-1]\")) {\n";
  print OUT"      print_$func_name"."_error(\"init_acc_$func_name -> VSsetfields: Unable to set fields.\");\n";
  print OUT"      return(-1);\n  }\n";
}
print OUT"  return(num_rec);\n}\n\n";

print OUT"/* Included for backwards compatability */\n\n";
print OUT"int32 init_rd_$func_name(int32 hdf_fp, int32 sd_id, char *access_mode)\n{ ";
print OUT"return ( init_acc_$func_name(hdf_fp, sd_id, access_mode) ); }\n";

         #####################
#########output: read function#########
print OUT"\n/******---- read function ----******/\n\n";

print OUT"int32 read_$func_name($structure *$part_name"."_struc, int32 recnum_rd)\n{\n";
	#does the structure contain SD data
$SD_index > 0 &&  print OUT"int32 start\[$maxdimplus1\], edges\[$maxdimplus1\];\n";

	#does the structure contain V data
if ($V_index > 0) {
  print OUT"int32 maxrec;\n";
}
print OUT"static int32 last_recnum = -1;\n";
print OUT"int32 retval = 0;\nuint8 *odata;\n\n";
print OUT"void print_$func_name"."_error();\n";
print OUT"void unpack_$func_name();\n\n";

print OUT"  if(recnum_rd==-1) recnum_rd=last_recnum+1;\n\n";


	#does the structure contain SD data
if ($SD_index > 0) {
  print OUT"  start[0] = recnum_rd;\n";
  for ($c2=1; $c2<=$maxdim; $c2++){
    print OUT"  start\[$c2\] = 0;\n";
  }
  print OUT"\n  edges\[0\] = 1;\n\n";
}
print OUT"  odata = (uint8 *) malloc(sizeof($structure));\n";
	#does the structure contain V data
if ($V_index > 0) {
  print OUT"  VSinquire(vdata_id_$func_name, &maxrec, NULL, NULL, NULL, NULL);\n";
  print OUT"  if (recnum_rd >= maxrec) return(-1);\n";
  print OUT"  if (recnum_rd != last_recnum+1)\n";
  print OUT"      if (VSseek(vdata_id_$func_name, recnum_rd)==FAIL) {\n";
  print OUT"          print_$func_name"."_error(\"read_$func_name -> VSseek unsuccessful\");\n";
  print OUT"          retval = -1;\n    }\n";
  print OUT"  last_recnum = recnum_rd;\n\n";
}
for ($c1=0; $c1<$SD_index; $c1++){
  $rank = ($dim[$c1][0]+1);
  for ($c2=1; $c2<$rank; $c2++){
    print OUT"  edges\[$c2\] = $dim[$c1][$c2];\n";
  }
  $c1plus1 = $c1 + 1;
  print OUT"\n  if(SDreaddata(sds_id_$func_name"."$c1plus1,start,NULL,edges, "; 
  print OUT"(VOIDP)($part_name"."_struc->$SD_name[$c1] )) ==FAIL) {\n";
  print OUT"    print_$func_name"."_error(\"read_$func_name -> SDreaddata: Couldn't read $SD_name[$c1]\");\n";
  print OUT"    retval = -1;\n  }\n";
}
	#does the structure contain V data
if ($V_index > 0) {
  print OUT"  if(VSread(vdata_id_$func_name, (uint8 *)odata, 1, FULL_INTERLACE) ==FAIL) {\n";
  print OUT"    print_$func_name"."_error(\"read_$func_name -> VSread: Couldn't read data.\");\n";
  print OUT"    retval = -1;\n  }\n";
}
print OUT"  unpack_$func_name(odata, $part_name"."_struc);\n";
print OUT"  free(odata);\n  return(retval);\n}\n";

#########output: close read function
print OUT"\n/*----   close read function    ----*/\n\n";
print OUT"void close_rd_$func_name()\n{\n";
	#does the structure contain V data
$V_index > 0 &&  print OUT"  VSdetach(vdata_id_$func_name);\n";

for ($cc=1; $cc<=$SD_index; $cc++){
  print OUT"  SDendaccess(sds_id_$func_name"."$cc);\n";
}
print OUT"}\n";

###########output: Read V group description function################
print OUT"\n/*----  Read V group description, function    ----*/\n";

print OUT"void rd_Vgrp_desc_$func_name(int32 hdf_fp, int32 an_id)\n{\n";
print OUT"  int32 ann_id_r;\n";
print OUT"  int32 num_ann;\n";
print OUT"  int32 *ann_list;\n";
print OUT"  int32 vgrp_ref_r;\n\n";

print OUT"void print_$func_name"."_error();\n";

print OUT"\n  /*      Get the Vgroup reference     */\n";
print OUT"  if ((vgrp_ref_r = Vfind(hdf_fp, \"VG_$part_name\" )) ==FAIL)\n";
print OUT"    print_$func_name"."_error(\"rd_Vgrp_$func_name -> Vfind: Couldn't get Vgrp reference.\");\n\n";

print OUT"  if ((num_ann = ANnumann(an_id, AN_DATA_DESC, DFTAG_VG, vgrp_ref_r)) ==FAIL)\n";
print OUT"    print_$func_name"."_error(\"rd_Vgrp_$func_name -> ANnumann: Couldn't get number of annotations.\");\n\n";

print OUT"printf(\"1numann= %d \\n\", num_ann);\n";


print OUT"    ann_list = HDmalloc(num_ann * sizeof(int32));\n";

print OUT"printf(\"1ann_list= %d \\n\", ann_list);\n";

print OUT"  if ((num_ann = ANannlist(an_id, AN_DATA_DESC, DFTAG_VG, vgrp_ref_r, ann_list)) ==FAIL)\n";
print OUT"    print_$func_name"."_error(\"rd_Vgrp_$func_name -> ANannlist: Couldn't\");\n\n";

print OUT"printf(\"2numann= %d \\n\", num_ann);\n";
print OUT"printf(\"2ann_list= %d \\n\", ann_list);\n";

print OUT"  if ((ann_id_r = ANselect(an_id, (num_ann-1), AN_DATA_DESC)) ==FAIL)\n";
print OUT"    print_$func_name"."_error(\"rd_Vgrp_$func_name -> ANselect: Couldn't\");\n\n";


print OUT"  if (ANreadann(ann_id_r, Vgrp_descrp_$part_name, HDstrlen(Vgrp_descrp_$part_name)) ==FAIL)\n";
print OUT"    print_$func_name"."_error(\"rd_Vgrp_$func_name -> ANreadann: Couldn't\");\n\n";

print OUT"  printf(\"AN: %s\\n\", Vgrp_descrp_$part_name);\n";

print OUT"  ANendaccess(ann_id_r);\n";

print OUT"  ANend(an_id);\n";

print OUT"}\n";

#########output: error function
print OUT"\n/*----   error function    ----*/\n\n";
print OUT"void print_$func_name"."_error(int8 *mess)\n{\n";
print OUT"  fprintf(stderr,\"\\nERROR in  $out_file -> %s\\n\", mess);\n";
print OUT"  HEprint(stderr, 0);\n}\n";

###########output: pack function################
print OUT"\n/*----   pack function    ----*/\n\n";

print OUT"void pack_$func_name(uint8 *data, ";
print OUT"$structure *$part_name"."_ptr)\n{\n";
print OUT"int32 ptr=0;\n\n";

for ($cc=0; $cc<$V_index; $cc++){
	#if the dimension is reported in a variable name, or has an operator
	# contained within it, mark it as multi-dimensional (ie > 1).
  if ($V_dim[$cc] =~ /[a-zA-Z\*\+\/-]/){
    $dim_value = 999;
  }else {
    $dim_value = $V_dim[$cc];
  }
  if ($dim_value == 1 ){
    print OUT"   memcpy(data+ptr, &$part_name"."_ptr->$V_name[$cc],";
  }else {
	#sets pointer to first element address
    print OUT"   memcpy(data+ptr, &$part_name"."_ptr->$V_name[$cc]"."[0],";
  }
  print OUT" (($V_base[$cc])*($V_dim[$cc])) );\n";
  print OUT"   ptr+= (($V_base[$cc])*($V_dim[$cc]));\n";
}
print OUT"}\n";

###########output: unpack function################
print OUT"\n/*----   unpack function    ----*/\n\n";

print OUT"void unpack_$func_name(uint8 *data, ";
print OUT"$structure *$part_name"."_ptr)\n{\n";
print OUT"int32 ptr=0;\n\n";

for ($cc=0; $cc<$V_index; $cc++){
	#if the dimension is contained in a variable name, or has an operator
	# contained within it, mark it as multi-dimensional (ie > 1).
  if ($V_dim[$cc] =~ /[a-zA-Z\*\+\/-]/){
    $dim_value = 999;
  }else {
    $dim_value = $V_dim[$cc];
  }
  if ($dim_value == 1 ){
    print OUT"   memcpy(&$part_name"."_ptr->$V_name[$cc], data+ptr, ";
  }else {
    print OUT"   memcpy(&$part_name"."_ptr->$V_name[$cc]"."[0], data+ptr, ";
  }
  print OUT" (($V_base[$cc])*($V_dim[$cc])) );\n";
  print OUT"   ptr+= (($V_base[$cc])*($V_dim[$cc]));\n";
}
print OUT"}\n";
###########output: V group idvalue ################

print OUT"int32 get_vgrp_id_$func_name() {";
print OUT"return(vgrp_id_$func_name);}\n";

###########output: V group description function################
	#use close to reset back to first line of input file
close (IN);
	#reopen .h file
open (IN,"$input_file") || die "ERROR: can't open input file '$input_file' 2nd time";

print OUT"\n/*----   V group description function    ----*/\n\n";

print OUT"int32 wr_Vgrp_desc_$func_name(char *wr_strval)\n{\n";

print OUT"  strcpy(wr_strval, \"The file '$filename' is shown below, it was used to create the data in the Vgroup named 'VG_$part_name'.\\n\\n\");\n";

while ( defined($line = <IN>)) {
  chop $line;	#remove new line character
	#found a " then replace it with a \"
  if ( $line =~ /"/ ){
    $line =~ s/"/\\"/g;
  }
  if ( $line =~ /\$\Id:/ ){	#remove $ so RCS will not convert it
    $line =~ s/\$//;
  }
  print OUT"  strcat(wr_strval,\"$line\\n\");\n";
}
  print OUT"  return(0);\n}\n";

close (OUT);
close (IN);

#----------- subroutine: Check Vdata size ----------------#
sub size_chk_of_Vdata
{
	#put subroutine arguments into subroutine variables
  ($element_size, $base) = @_;
  if ($element_size == 0){
    $element_size = 1;
  }
  $base /= 8;
  $total_size += $element_size * $base;
	#total size can't exceed 64k
  if ($total_size >= 65536){
    warn"Warning: Max size for Vdata is 65536 bytes (64k).\n";
    warn"         The size of your Vdata is $total_size bytes.\n";
    warn"In hdfgen.pl you must reduce the value of \$MAX_ELEMENTS_FOR_VDATA\n";
    warn"and/or split up structure '$Struct_Name' into two different files.\n";
  }
}
