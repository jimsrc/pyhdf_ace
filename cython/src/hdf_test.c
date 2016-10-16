/* The RCS version of hdfgen.pl used to create this file is: */
/* $Id: hdfgen.pl,v 1.47 1998/07/28 00:22:51 steves Exp  */

/* The include file used to create this file is: */
/* $Id: structure.h,v 1.4 1997/04/25 17:58:31 steves Exp steves  */

#include "hdf_test.h"

/****----  init create function  ----****/

int32 init_cr_test_func(int32 hdf_fp, int32 sd_id, int32 an_id, char *classname)
{
  int32 retval=0;
  int32 vgrp_ref_w;
  int32 ann_id_w;
  int32 wr_Vgrp_desc_test_func();

  void print_test_func_error();

  /*         Setup a Vgroup         */
  if ((vgrp_id_test_func = Vattach(hdf_fp, -1, "w"))==FAIL) {
    print_test_func_error("init_cr_test_func -> Vattach: Couldn't create Vgroup");
    retval = -1;
  }
  Vsetname(vgrp_id_test_func, "VG_MAG_data_1sec"); 
  Vsetclass(vgrp_id_test_func, "VG_STRUCTURE");


  /*      Get the Vgroup reference     */
  if ((vgrp_ref_w = Vfind(hdf_fp, "VG_MAG_data_1sec" )) ==FAIL) {
    print_test_func_error("init_cr_test_func -> Vfind: Couldn't get Vgrp reference");
    retval = -1;
  }
  /*      Add a description to the Vgroup      */
  wr_Vgrp_desc_test_func(Vgrp_descrp_MAG_data_1sec);

  if ((ann_id_w = ANcreate(an_id, DFTAG_VG, vgrp_ref_w, AN_DATA_DESC)) ==FAIL) {
    print_test_func_error("init_cr_test_func -> ANcreate: Can't create Vgrp description");
    retval = -1;
  }
  if ((ANwriteann(ann_id_w, Vgrp_descrp_MAG_data_1sec, sizeof(Vgrp_descrp_MAG_data_1sec))) ==FAIL) {
    print_test_func_error("init_cr_test_func -> ANwriteann: Can't write Vgrp description");
    retval = -1;
  }
  ANendaccess(ann_id_w);

  /*        Setup a Vdata        */
  if ((vdata_id_test_func = VSattach(hdf_fp, -1, "w")) ==FAIL) {
    print_test_func_error("init_cr_test_func -> VSattach: Couldn't attach to Vdata");
    retval = -1;
  }
  VSsetname(vdata_id_test_func, "MAG_data_1sec");
  VSsetclass(vdata_id_test_func, classname);

  /*       Insert the Vdata into the Vgroup       */
  if ((Vinsert(vgrp_id_test_func, vdata_id_test_func)) ==FAIL) {
    print_test_func_error("init_cr_test_func -> Vinsert: Couldn't insert Vdata into Vgroup");
    retval = -1;
  }

  /*    Define the fields in the Vdata    */
  if (VSfdefine(vdata_id_test_func, "year", DFNT_INT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define year");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "day", DFNT_INT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define day");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "hr", DFNT_INT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define hr");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "min", DFNT_INT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define min");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "sec", DFNT_FLOAT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define sec");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "fp_year", DFNT_FLOAT64, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define fp_year");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "fp_doy", DFNT_FLOAT64, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define fp_doy");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "ACEepoch", DFNT_FLOAT64, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define ACEepoch");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "SCclock", DFNT_UINT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define SCclock");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "Br", DFNT_FLOAT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define Br");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "Bt", DFNT_FLOAT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define Bt");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "Bn", DFNT_FLOAT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define Bn");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "Bmag", DFNT_FLOAT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define Bmag");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "Delta", DFNT_FLOAT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define Delta");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "Lambda", DFNT_FLOAT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define Lambda");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "Bgse_x", DFNT_FLOAT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define Bgse_x");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "Bgse_y", DFNT_FLOAT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define Bgse_y");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "Bgse_z", DFNT_FLOAT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define Bgse_z");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "Bgsm_x", DFNT_FLOAT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define Bgsm_x");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "Bgsm_y", DFNT_FLOAT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define Bgsm_y");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "Bgsm_z", DFNT_FLOAT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define Bgsm_z");
    retval = -1;
  }
  if (VSfdefine(vdata_id_test_func, "Quality", DFNT_INT32, (1) )) {
    print_test_func_error("init_cr_test_func -> VSfdefine: Couldn't define Quality");
    retval = -1;
  }

  if (VSsetfields(vdata_id_test_func,"year, day, hr, min, sec, fp_year, fp_doy, ACEepoch, SCclock, Br, Bt, Bn, Bmag, Delta, Lambda, Bgse_x, Bgse_y, Bgse_z, Bgsm_x, Bgsm_y, Bgsm_z, Quality")){
    print_test_func_error("init_cr_test_func -> VSsetfields: Couldn't set fields");
    retval = -1;
  }

  return(retval);
}

/* Included for backwards compatibility */

int32 init_wr_test_func(int32 hdf_fp, int32 sd_id, int32 an_id, char *classname)
{ return( init_cr_test_func(hdf_fp, sd_id, an_id, classname) ); }

/******---- write function ----******/

int32 write_test_func(struct MAG_data_1sec MAG_data_1sec_struc, int32 recnum)
{
  int32 retval = 0;
  uint8 *odata;

void print_test_func_error();
void pack_test_func();

  odata = (uint8 *) malloc(sizeof(struct MAG_data_1sec));
  pack_test_func(odata, &MAG_data_1sec_struc);

  if(recnum!=-1) {
	if(VSseek(vdata_id_test_func, recnum)==-1) {
		print_test_func_error("write_test_func -> VSseek: error.");
		retval = -1;
	}
  }
  if(VSwrite(vdata_id_test_func, (uint8 *)odata, 1, FULL_INTERLACE) == -1)
    print_test_func_error("write_test_func -> VSwrite: Couldn't write data.");

  memset(&MAG_data_1sec_struc, 0, sizeof(struct MAG_data_1sec));
  free(odata);
  return(retval);
}

/*----   close write function    ----*/

void close_wr_test_func()
{
  VSdetach(vdata_id_test_func);
  Vdetach(vgrp_id_test_func);
}

/*----     init access function    ----*/

int32 init_acc_test_func(int32 hdf_fp, int32 sd_id, char *access_mode)
{
  int32 vdata_ref;
  int32 num_rec;

  void print_test_func_error();


  if ((vdata_ref = VSfind(hdf_fp, "MAG_data_1sec")) <= 0 ) {
    print_test_func_error("init_acc_test_func -> VSfind: Found no vdata of specified type.");
    return(0);
  }
  if ((vdata_id_test_func = VSattach(hdf_fp, vdata_ref, access_mode)) ==FAIL) {
    print_test_func_error("init_acc_test_func -> VSattach: Couldn't attach to hdf file.");
    return(-1);
  }

  VSinquire(vdata_id_test_func, &num_rec, NULL, NULL, NULL, NULL);
  if (num_rec == 0) { return(0); }


  if (VSsetfields(vdata_id_test_func,"year, day, hr, min, sec, fp_year, fp_doy, ACEepoch, SCclock, Br, Bt, Bn, Bmag, Delta, Lambda, Bgse_x, Bgse_y, Bgse_z, Bgsm_x, Bgsm_y, Bgsm_z, Quality")) {
      print_test_func_error("init_acc_test_func -> VSsetfields: Unable to set fields.");
      return(-1);
  }
  return(num_rec);
}

/* Included for backwards compatability */

int32 init_rd_test_func(int32 hdf_fp, int32 sd_id, char *access_mode)
{ return ( init_acc_test_func(hdf_fp, sd_id, access_mode) ); }

/******---- read function ----******/

int32 read_test_func(struct MAG_data_1sec *MAG_data_1sec_struc, int32 recnum_rd)
{
int32 maxrec;
static int32 last_recnum = -1;
int32 retval = 0;
uint8 *odata;

void print_test_func_error();
void unpack_test_func();

  if(recnum_rd==-1) recnum_rd=last_recnum+1;

  odata = (uint8 *) malloc(sizeof(struct MAG_data_1sec));
  VSinquire(vdata_id_test_func, &maxrec, NULL, NULL, NULL, NULL);
  if (recnum_rd >= maxrec) return(-1);
  if (recnum_rd != last_recnum+1)
      if (VSseek(vdata_id_test_func, recnum_rd)==FAIL) {
          print_test_func_error("read_test_func -> VSseek unsuccessful");
          retval = -1;
    }
  last_recnum = recnum_rd;

  if(VSread(vdata_id_test_func, (uint8 *)odata, 1, FULL_INTERLACE) ==FAIL) {
    print_test_func_error("read_test_func -> VSread: Couldn't read data.");
    retval = -1;
  }
  unpack_test_func(odata, MAG_data_1sec_struc);
  free(odata);
  return(retval);
}

/*----   close read function    ----*/

void close_rd_test_func()
{
  VSdetach(vdata_id_test_func);
}

/*----  Read V group description, function    ----*/
void rd_Vgrp_desc_test_func(int32 hdf_fp, int32 an_id)
{
  int32 ann_id_r;
  int32 num_ann;
  int32 *ann_list;
  int32 vgrp_ref_r;

void print_test_func_error();

  /*      Get the Vgroup reference     */
  if ((vgrp_ref_r = Vfind(hdf_fp, "VG_MAG_data_1sec" )) ==FAIL)
    print_test_func_error("rd_Vgrp_test_func -> Vfind: Couldn't get Vgrp reference.");

  if ((num_ann = ANnumann(an_id, AN_DATA_DESC, DFTAG_VG, vgrp_ref_r)) ==FAIL)
    print_test_func_error("rd_Vgrp_test_func -> ANnumann: Couldn't get number of annotations.");

printf("1numann= %d \n", num_ann);
    ann_list = HDmalloc(num_ann * sizeof(int32));
printf("1ann_list= %d \n", ann_list);
  if ((num_ann = ANannlist(an_id, AN_DATA_DESC, DFTAG_VG, vgrp_ref_r, ann_list)) ==FAIL)
    print_test_func_error("rd_Vgrp_test_func -> ANannlist: Couldn't");

printf("2numann= %d \n", num_ann);
printf("2ann_list= %d \n", ann_list);
  if ((ann_id_r = ANselect(an_id, (num_ann-1), AN_DATA_DESC)) ==FAIL)
    print_test_func_error("rd_Vgrp_test_func -> ANselect: Couldn't");

  if (ANreadann(ann_id_r, Vgrp_descrp_MAG_data_1sec, HDstrlen(Vgrp_descrp_MAG_data_1sec)) ==FAIL)
    print_test_func_error("rd_Vgrp_test_func -> ANreadann: Couldn't");

  printf("AN: %s\n", Vgrp_descrp_MAG_data_1sec);
  ANendaccess(ann_id_r);
  ANend(an_id);
}

/*----   error function    ----*/

void print_test_func_error(int8 *mess)
{
  fprintf(stderr,"\nERROR in  hdf_test.c -> %s\n", mess);
  HEprint(stderr, 0);
}

/*----   pack function    ----*/

void pack_test_func(uint8 *data, struct MAG_data_1sec *MAG_data_1sec_ptr)
{
int32 ptr=0;

   memcpy(data+ptr, &MAG_data_1sec_ptr->year, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->day, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->hr, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->min, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->sec, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->fp_year, ((8)*(1)) );
   ptr+= ((8)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->fp_doy, ((8)*(1)) );
   ptr+= ((8)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->ACEepoch, ((8)*(1)) );
   ptr+= ((8)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->SCclock, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->Br, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->Bt, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->Bn, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->Bmag, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->Delta, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->Lambda, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->Bgse_x, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->Bgse_y, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->Bgse_z, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->Bgsm_x, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->Bgsm_y, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->Bgsm_z, ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(data+ptr, &MAG_data_1sec_ptr->Quality, ((4)*(1)) );
   ptr+= ((4)*(1));
}

/*----   unpack function    ----*/

void unpack_test_func(uint8 *data, struct MAG_data_1sec *MAG_data_1sec_ptr)
{
int32 ptr=0;

   memcpy(&MAG_data_1sec_ptr->year, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->day, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->hr, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->min, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->sec, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->fp_year, data+ptr,  ((8)*(1)) );
   ptr+= ((8)*(1));
   memcpy(&MAG_data_1sec_ptr->fp_doy, data+ptr,  ((8)*(1)) );
   ptr+= ((8)*(1));
   memcpy(&MAG_data_1sec_ptr->ACEepoch, data+ptr,  ((8)*(1)) );
   ptr+= ((8)*(1));
   memcpy(&MAG_data_1sec_ptr->SCclock, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->Br, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->Bt, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->Bn, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->Bmag, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->Delta, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->Lambda, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->Bgse_x, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->Bgse_y, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->Bgse_z, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->Bgsm_x, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->Bgsm_y, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->Bgsm_z, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
   memcpy(&MAG_data_1sec_ptr->Quality, data+ptr,  ((4)*(1)) );
   ptr+= ((4)*(1));
}
int32 get_vgrp_id_test_func() {return(vgrp_id_test_func);}

/*----   V group description function    ----*/

int32 wr_Vgrp_desc_test_func(char *wr_strval)
{
  strcpy(wr_strval, "The file 'structure.h' is shown below, it was used to create the data in the Vgroup named 'VG_MAG_data_1sec'.\n\n");
  strcat(wr_strval,"/* Id: structure.h,v 1.4 1997/04/25 17:58:31 steves Exp steves $ */\n");
  strcat(wr_strval,"/* The line above is a revision control system (rcs) header and is needed so */\n");
  strcat(wr_strval,"/* the perl program (hdfgen.pl) will not complain that this include file */\n");
  strcat(wr_strval,"/* doesn't have an rcs header. */\n");
  strcat(wr_strval,"#include \"hdfi.h\"\n");
  strcat(wr_strval,"\n");
  strcat(wr_strval,"struct MAG_data_1sec {\n");
  strcat(wr_strval,"\n");
  strcat(wr_strval,"  /* UT time at the start of the periods */\n");
  strcat(wr_strval,"  int32   year;                         /* integer year */\n");
  strcat(wr_strval,"  int32   day;                          /* integer day of year */\n");
  strcat(wr_strval,"  int32   hr;                           /* hour of day */\n");
  strcat(wr_strval,"  int32   min;                          /* min of hour */\n");
  strcat(wr_strval,"  float32 sec;                          /* seconds */\n");
  strcat(wr_strval,"  float64 fp_year;                      /* floating point year */\n");
  strcat(wr_strval,"  float64 fp_doy;                       /* floating point Day of YearDOY */ \n");
  strcat(wr_strval,"  float64 ACEepoch;                     /* UT time in sec since 1/1/96 */\n");
  strcat(wr_strval,"\n");
  strcat(wr_strval,"  /* ACE frame count */\n");
  strcat(wr_strval,"  uint32 SCclock;\n");
  strcat(wr_strval,"      \n");
  strcat(wr_strval,"  /* mag average data */\n");
  strcat(wr_strval,"  float32 Br;\n");
  strcat(wr_strval,"  float32 Bt;\n");
  strcat(wr_strval,"  float32 Bn;\n");
  strcat(wr_strval,"\n");
  strcat(wr_strval,"  float32 Bmag;\n");
  strcat(wr_strval,"  float32 Delta;\n");
  strcat(wr_strval,"  float32 Lambda;\n");
  strcat(wr_strval,"\n");
  strcat(wr_strval,"  float32 Bgse_x;\n");
  strcat(wr_strval,"  float32 Bgse_y;\n");
  strcat(wr_strval,"  float32 Bgse_z;\n");
  strcat(wr_strval,"\n");
  strcat(wr_strval,"  float32 Bgsm_x;\n");
  strcat(wr_strval,"  float32 Bgsm_y;\n");
  strcat(wr_strval,"  float32 Bgsm_z;\n");
  strcat(wr_strval,"\n");
  strcat(wr_strval,"  /* data quality for period */\n");
  strcat(wr_strval,"  int32  Quality;                      /* =0 Normal; */\n");
  strcat(wr_strval,"                                       /* =1 Maneuver & Relaxation*/\n");
  strcat(wr_strval,"				       /* =2 Bad data */\n");
  strcat(wr_strval,"};\n");
  return(0);
}
