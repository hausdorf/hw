/**
 * File To Object
 *
 * CS 3505
 * Authors: Landon Gilber-Bland and Alex Clemmer
 * Date: Spring 2011
 *
 * Read data from file into list of objects
 */

#include <stdio.h> // C (.h), printf scanf FILE et al
#include <sstream> // C++ (no .h)
#include <stdlib.h> // C (.h) exit, other nice funcs
#include <vector>
#include <iostream>

#include "Student.h"
#include "Helpers.h"
#include "Matcher.h"
#include "Group.h"

int main(int arg_count, char *arg_list[]) {
  FILE *file;

  // if no args, open default
  if (arg_count == 1) {
    file = fopen("student_info", "r");
  }
  // else open from args
  else {
    file = fopen(arg_list[1], "r");
  }

  if(!file) {
    printf("Error opening student_info file!\n");
    exit(-1);
  }

  std::vector<Student> students;
  char line[1000];
  int count = 0;
  bool verbose = false;

  printf("Reading file\n");

  while(fgets(line, 1000, file) && count < 1000) {
    students.push_back(*(new Student()));
    students[count].parseLine(line);
    if(verbose) {
      printf("%s\n", students[count].toString().c_str());
    }
    count++;
  }

  printf("File Read\n");

  Matcher::match(students);

  printf("DONE!\n");
}
