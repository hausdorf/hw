/********************************************************
 * Kernels to be optimized for the CS:APP Performance Lab
 ********************************************************/

#include <stdio.h>
#include <stdlib.h>
#include "defs.h"

/* 
 * Please fill in the following student struct 
 */
student_t student = {
  "Alex Clemmer",     /* Student full name */
  "clemmer",    /* Student CADE login */
  "clemmer.alexander@gmail.com",  /* Student email address */
};

/***************
 * ROTATE KERNEL
 ***************/

/******************************************************
 * Your different versions of the rotate kernel go here
 ******************************************************/

/* 
 * naive_rotate - The naive baseline version of rotate 
 */
char naive_rotate_descr[] = "naive_rotate: Naive baseline implementation";
void naive_rotate(int dim, pixel *src, pixel *dst) 
{
  int i, j;
  
  for (i = 0; i < dim; i++)
    for (j = 0; j < dim; j++)
      dst[RIDX(j, dim-1-i, dim)] = src[RIDX(i, j, dim)];
}

char less_naive_rotate_descr[] = "less_naive_rotate: slightly better than baseline";
void less_naive_rotate(int dim, pixel *src, pixel *dst) 
{
  int i, j = 0;
  int tmp0, tmp1, tmp2, tmp3;
  pixel acc1, acc2;
  
  for (i = 0; i < dim; i++) {
    for (j = 0; j < dim - 1; j+=2) {
      tmp0 = RIDX(i,j,dim);
      tmp1 = RIDX(i,j+1,dim);
      tmp2 = RIDX(j,dim-1-i,dim);
      tmp3 = RIDX(j+1,dim-1-i,dim);

      acc1 = src[tmp0];
      acc2 = src[tmp1];

      dst[tmp2] = acc1;
      dst[tmp3] = acc2;
    }

    for (; j < dim; j++)
      dst[RIDX(j, dim - 1 - i, dim)] = src[RIDX(i, j, dim)];
  }
}

/*
 * This is an incredibly simple optimization: all we do is partition the image up into
 * blocks of 8*8 and do those individually. It's really that simple.
 */
char less_less_naive_rotate_descr[] = "less_less_naive_rotate: slightly better than baseline";
void less_less_naive_rotate(int dim, pixel *src, pixel *dst) 
{
  int i, j, k, l;
  int blocksizei = 16;
  int blocksizej = 8;
  
  for (i = 0; i < dim; i += blocksizei) {
    for (j = 0; j < dim; j += blocksizej) {
      for (k = i; k < i + blocksizei; k++) {
        for (l = j; l < j + blocksizej; l++) {
          dst[RIDX(l, dim-1-k, dim)] = src[RIDX(k, l, dim)];
        }
      }
    }
  }
}

/* 
 * rotate - Your current working version of rotate
 * IMPORTANT: This is the version you will be graded on
 */
char rotate_descr[] = "rotate: Current working version";
void rotate(int dim, pixel *src, pixel *dst) 
{
  less_less_naive_rotate(dim, src, dst);
}

/*********************************************************************
 * register_rotate_functions - Register all of your different versions
 *     of the rotate kernel with the driver by calling the
 *     add_rotate_function() for each test function. When you run the
 *     driver program, it will test and report the performance of each
 *     registered test function.  
 *********************************************************************/

void register_rotate_functions() 
{
  //add_rotate_function(&naive_rotate, naive_rotate_descr);   
  add_rotate_function(&rotate, rotate_descr);   
  //add_rotate_function(&less_naive_rotate, less_naive_rotate_descr);   
  //add_rotate_function(&less_less_naive_rotate, less_less_naive_rotate_descr);   
}


/***************
 * SMOOTH KERNEL
 **************/

/***************************************************************
 * Various typedefs and helper functions for the smooth function
 * You may modify these any way you like.
 **************************************************************/

/* A struct used to compute averaged pixel value */
typedef struct {
  int red;
  int green;
  int blue;
  int num;
} pixel_sum;

/* Compute min and max of two integers, respectively */
static int min(int a, int b) { return (a < b ? a : b); }
static int max(int a, int b) { return (a > b ? a : b); }

/* 
 * initialize_pixel_sum - Initializes all fields of sum to 0 
 */
static inline void initialize_pixel_sum(pixel_sum *sum) 
{
  sum->red = sum->green = sum->blue = 0;
  sum->num = 0;
  return;
}

/* 
 * accumulate_sum - Accumulates field values of p in corresponding 
 * fields of sum 
 */
static inline void accumulate_sum(pixel_sum *sum, pixel p) 
{
  sum->red += (int) p.red;
  sum->green += (int) p.green;
  sum->blue += (int) p.blue;
  sum->num++;
  return;
}

/* 
 * assign_sum_to_pixel - Computes averaged pixel value in current_pixel 
 */
static inline void assign_sum_to_pixel(pixel *current_pixel, pixel_sum sum) 
{
  current_pixel->red = (unsigned char) (sum.red/sum.num);
  current_pixel->green = (unsigned char) (sum.green/sum.num);
  current_pixel->blue = (unsigned char) (sum.blue/sum.num);
  return;
}

/* 
 * avg - Returns averaged pixel value at (i,j) 
 */
static inline pixel avg(int dim, int i, int j, pixel *src) 
{
  int ii, jj;
  pixel_sum sum;
  pixel current_pixel;
  
  initialize_pixel_sum(&sum);
  for(ii = max(i-1, 0); ii <= min(i+1, dim-1); ii++) 
    for(jj = max(j-1, 0); jj <= min(j+1, dim-1); jj++) {
      accumulate_sum(&sum, src[RIDX(ii, jj, dim)]);
      // "weighted" averge: add (i,j) pixel to sum twice
      if(ii == i && jj == j)
        accumulate_sum(&sum, src[RIDX(ii, jj, dim)]);
    }
  
  assign_sum_to_pixel(&current_pixel, sum);
  return current_pixel;
}

/******************************************************
 * Your different versions of the smooth kernel go here
 ******************************************************/

static inline void sum_row(pixel_sum *sums, int dim, pixel *row)
{
  int i;
  //add_two_pixels(sums++, row, row + 1);
  sums->red = row->red + (row + 1)->red;
  sums->green = row->green + (row + 1)->green;
  sums->blue = row->blue + (row + 1)->blue;
  sums++;
  row++;

  for (i = 1; i < dim - 1; i++) {
    //add_three_pixels(sums++, row - 1, row, row + 1);
    sums->red = (row - 1)->red + row->red + (row + 1)->red;
    sums->green = (row - 1)->green + row->green + (row + 1)->green;
    sums->blue = (row - 1)->blue + row->blue + (row + 1)->blue;
    sums++;
    row++;
  }

  //add_two_pixels(sums, row - 1, row);
  sums->red = row->red + (row - 1)->red;
  sums->green = row->green + (row - 1)->green;
  sums->blue = row->blue + (row - 1)->blue;
}

/*
 * naive_smooth - The naive baseline version of smooth 
 */
char naive_smooth_descr[] = "naive_smooth: Naive baseline implementation";
void naive_smooth(int dim, pixel *src, pixel *dst) 
{
  int i, j;
  
  for (i = 0; i < dim; i++)
    for (j = 0; j < dim; j++)
      dst[RIDX(i, j, dim)] = avg(dim, i, j, src);
}

/*
 * smooth - Your current working version of smooth. 
 * IMPORTANT: This is the version you will be graded on
 */
char smooth_descr[] = "smooth: Current working version";
void smooth(int dim, pixel *src, pixel *dst) 
{
  int m,n;
  /* ------- SET UP DST ARRAY -------- */
  for (m=0; m<dim; m++) {
    for (n=0; n<dim; n++) {
      int qt = RIDX(m,n,dim);
      dst[qt].red = src[qt].red;
      dst[qt].green = src[qt].green;
      dst[qt].blue = src[qt].blue;
    }
  }
  /* --------------- */

  pixel_sum *row_sums = malloc(3*dim*sizeof(pixel_sum));
  pixel_sum *row0 = row_sums;
  pixel_sum *row1 = row0+dim;
  pixel_sum *row2;

  int i,j;

  sum_row(row0, dim, src);
  sum_row(row1, dim, src+dim);

  /* ------- COMPUTE AVERAGES FOR FIRST ROW -------- */
  //avg_two_pixel_sums(dst++, row0++, row1++, 5);
  dst->red = (dst->red + row0->red + row1->red) / 5;
  dst->green = (dst->green + row0->green + row1->green) / 5;
  dst->blue = (dst->blue + row0->blue + row1->blue) / 5;
  dst++;
  row0++;
  row1++;

  for (i=1; i<dim-1; i++) {
    //avg_two_pixel_sums(dst++, row0++, row1++, 7);
    dst->red = (dst->red + row0->red + row1->red) / 7;
    dst->green = (dst->green + row0->green + row1->green) / 7;
    dst->blue = (dst->blue + row0->blue + row1->blue) / 7;
    dst++;
    row0++;
    row1++;
  }

  //avg_two_pixel_sums(dst++, row0, row1, 5);
  dst->red = (dst->red + row0->red + row1->red) / 5;
  dst->green = (dst->green + row0->green + row1->green) / 5;
  dst->blue = (dst->blue + row0->blue + row1->blue) / 5;
  dst++;
  /* --------------- */

  /* ------- COMPUTE AVERAGES FOR MIDDLE ROWS -------- */
  for (i=1; i<dim-1; i++) {
    row0 = row_sums + ((i-1)%3)*dim;
    row1 = row_sums + (i%3)*dim;
    row2 = row_sums + ((i+1)%3)*dim;

    /* ------- First element -------- */
    sum_row(row2, dim, src + (i+1)*dim);
    //avg_three_pixel_sums(dst++, row0++, row1++, row2++, 7);
    dst->red = (dst->red + row0->red + row1->red + row2->red) / 7;
    dst->green = (dst->green + row0->green + row1->green + row2->green) / 7;
    dst->blue = (dst->blue + row0->blue + row1->blue + row2->blue) / 7;
    dst++;
    row0++;
    row1++;
    row2++;
    /* --------------- */

    /* ------- Middle elements -------- */
    for (j=1; j<dim-1; j++) {
      //avg_three_pixel_sums(dst++, row0++, row1++, row2++, 10);
      dst->red = (dst->red + row0->red + row1->red + row2->red) / 10;
      dst->green = (dst->green + row0->green + row1->green + row2->green) / 10;
      dst->blue = (dst->blue + row0->blue + row1->blue + row2->blue) / 10;
      dst++;
      row0++;
      row1++;
      row2++;
    }
    /* --------------- */

    /* ------- Last elements -------- */
    //avg_three_pixel_sums(dst++, row0, row1, row2, 7);
    dst->red = (dst->red + row0->red + row1->red + row2->red) / 7;
    dst->green = (dst->green + row0->green + row1->green + row2->green) / 7;
    dst->blue = (dst->blue + row0->blue + row1->blue + row2->blue) / 7;
    dst++;
    row0++;
    row1++;
    row2++;
    /* --------------- */
  }
  /* --------------- */

  row0 = row_sums + ((i-1)%3)*dim;
  row1 = row_sums + (i%3)*dim;

  /* ------- COMPUTE AVERAGES FOR LAST ROW -------- */
  /* ------- First element -------- */
  //avg_two_pixel_sums(dst++, row0++, row1++, 5);
  dst->red = (dst->red + row0->red + row1->red) / 5;
  dst->green = (dst->green + row0->green + row1->green) / 5;
  dst->blue = (dst->blue + row0->blue + row1->blue) / 5;
  dst++;
  row0++;
  row1++;
  /* --------------- */

  /* ------- Middle elements -------- */
  for (i=1; i<dim-1; i++) {
    //avg_two_pixel_sums(dst++, row0++, row1++, 7);
    dst->red = (dst->red + row0->red + row1->red) / 7;
    dst->green = (dst->green + row0->green + row1->green) / 7;
    dst->blue = (dst->blue + row0->blue + row1->blue) / 7;
    dst++;
    row0++;
    row1++;
  }
  /* --------------- */

  /* ------- Last element -------- */
  //avg_two_pixel_sums(dst, row0, row1, 5);
  dst->red = (dst->red + row0->red + row1->red) / 5;
  dst->green = (dst->green + row0->green + row1->green) / 5;
  dst->blue = (dst->blue + row0->blue + row1->blue) / 5;
  /* --------------- */
  /* --------------- */
}


/********************************************************************* 
 * register_smooth_functions - Register all of your different versions
 *     of the smooth kernel with the driver by calling the
 *     add_smooth_function() for each test function.  When you run the
 *     driver program, it will test and report the performance of each
 *     registered test function.  
 *********************************************************************/

void register_smooth_functions() {
  add_smooth_function(&naive_smooth, naive_smooth_descr);
  add_smooth_function(&smooth, smooth_descr);
}
