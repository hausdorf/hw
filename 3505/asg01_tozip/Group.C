/**
 * Group.C
 * CS 3505
 * Authors: Landon Gilbert-Bland and Alex Clemmer
 *
 * .C file for Group.h. Contains the implementing code
 */
#include "Group.h"
#include <string>

bool Group::isFull() {
  if(students.size() == 4) {
    return true;
  }
  return false;
}

bool Group::isEmpty() {
  if(students.size() == 0) {
    return true;
  }
  return false;
}

void Group::removeLastStudent() {
  students.pop_back();
}

void Group::addStudent(Student s) {
  students.push_back(s);
}

int Group::getSize() { 
  return students.size();
}

std::vector<Student> Group::getStudents() {
  return students;
}

std::string Group::toString() {
  std::string s;
  for(unsigned i=0; i<students.size(); i++) {
    s += students.at(i).name + " ";
  }

  return s;
}
