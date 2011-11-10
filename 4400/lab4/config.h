/*********************************************************
 * config.h - Configuration data for the driver.c program.
 *********************************************************/
#ifndef _CONFIG_H_
#define _CONFIG_H_

/* 
 * CPEs for the baseline (naive) version of the rotate function that
 * was handed out to the students. Rd is the measured CPE for a dxd
 * image. Run the driver.c program on your system to get these
 * numbers.  
 */
#define R128   6
#define R256   9
#define R512   12
#define R1024  22
#define R2048  30
#define R4096  37

/* 
 * CPEs for the baseline (naive) version of the smooth function that
 * was handed out to the students. Sd is the measure CPE for a dxd
 * image. Run the driver.c program on your system to get these
 * numbers.  
 */

#define S32   109
#define S64   109
#define S128  110
#define S256  111
#define S512  114
#define S1024  119

#endif /* _CONFIG_H_ */
