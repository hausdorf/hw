/**
 * Student.C
 * CS 3505
 * Authors: Landon Gilbert-Bland and Alex Clemmer
 * Date: Spring 2011
 *
 * Defines member functions of Student.h
 */
#include <stdlib.h>
#include <iostream>
#include "Student.h"
#include "Helpers.h"

using namespace std;

string Student::toString() {
  string result = name + "," + level + ": ";

  for(unsigned i=0;i<times.size();i++) {
    result += IntToString(times[i]) + ", ";
  }
  return result;
}

void Student::parseLine(string line) {
  size_t start = 0;
  size_t end = line.find(" ", start);

  // name is line[0] to the index of the first space
  name = line.substr(start, end);

  // Check for the optional prefered students
  while(true) {
    start = end + 1;
    end = line.find(" ", start);
    string tmp = line.substr(start, end - start);
    if(tmp == "excellent" ||
       tmp == "good"      ||
       tmp == "average"   ||
       tmp == "poor"      ||
       tmp == "not_saying") {
      level = tmp;
      break;
    }
    else {
      preferedTeammates.push_back(tmp);
    }
  }

  // Move forward to start parsing out the times someone can meet
  start = end + 1;
  end = line.find(" ", start);

  string current_number;

  // parse out each meeting time, put in vector times
  while(end != string::npos) {
    current_number = line.substr(start, end-start);
    int time = StringToInt(current_number);
    addTime(time);

    start = end + 1;
    end = line.find(" ", start);
  }

  // Get the last number
  current_number = line.substr(start, end-start);
  int time = StringToInt(current_number);
  addTime(time);
}


void Student::addTime(int time) {
  // Insert the item so it is in sorted location.
  times.push_back(time);
  for(unsigned i=times.size() - 1; i>0; i--) {
    if(times.at(i) < times.at(i - 1)) {
      int tmp = times.at(i);
      times.at(i) = times.at(i-1);
      times.at(i-1) = tmp;
    }
    else {
      break;
    }
  }
}

void Student::isAvaliable(bool b) {
  avaliable = b;
}

bool Student::isAvaliable() {
  return avaliable;
}

std::vector<int> Student::getHours() {
  return times;
}

Student::Student(const Student& p) {
	name = p.name;
	level = p.level;
	times = p.times;
	preferedTeammates = p.preferedTeammates;
  avaliable = p.avaliable;
}
