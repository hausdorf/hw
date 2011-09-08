/**
 * Helpers.C
 *
 * CS 3505
 * Compiled by: Landon Gilber-Bland and Alex Clemmer from Jim's jim_helper.h
 * Date: Spring 2011
 *
 * Various helper methods for Student scheduling problem
 */
#include <sstream>
#include <stdio.h>

#include "Helpers.h"

using namespace std;

string IntToString(int number) {
  stringstream ss;
  ss << number;
  return ss.str();
}

int StringToInt(string num_str) {
  int value;
  sscanf(num_str.c_str(), "%d", &value);
  return value;
}
