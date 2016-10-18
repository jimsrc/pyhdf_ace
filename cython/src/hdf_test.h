#ifndef HDFGEN_H
#define HDFGEN_H

#include "structure.h"
#include "df.h"

int32 vgrp_id_test_func;
static int32 vdata_id_test_func;

  /* 1527 is the size of structure.h + 1 added line */
char Vgrp_descrp_MAG_data_1sec[1527];


int32 init_cr_test_func(int32 hdf_fp, int32 sd_id, int32 an_id, char *classname);
void close_wr_test_func();
int32 init_acc_test_func(int32 hdf_fp, int32 sd_id, char *access_mode);
int32 init_rd_test_func(int32 hdf_fp, int32 sd_id, char *access_mode);
int32 read_test_func(struct MAG_data_1sec *MAG_data_1sec_struc, int32 recnum_rd);
void close_rd_test_func();
void rd_Vgrp_desc_test_func(int32 hdf_fp, int32 an_id);
void print_test_func_error(int8 *mess);
void pack_test_func(uint8 *data, struct MAG_data_1sec *MAG_data_1sec_ptr);
void unpack_test_func(uint8 *data, struct MAG_data_1sec *MAG_data_1sec_ptr);
int32 wr_Vgrp_desc_test_func(char *wr_strval);
int32 get_maxrec(void);

#endif //HDFGEN_H
