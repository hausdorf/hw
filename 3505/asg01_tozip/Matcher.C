/**
 * Matcher.C
 * CS 3505
 * Authors: Landon Gilbert-Bland and Alex Clemmer
 * Date: Spring 2011
 *
 * Defines members of Matcher.h
 */
#include <vector>
#include <stdio.h>
#include <iostream>

#include "Matcher.h"
#include "Student.h"
#include "Group.h"

using namespace std;

void Matcher::match(vector<Student>& students) {
  // The pointer to highest matches. A pointer so we can reeturn it as a 
  // result from this method (ie it needs to be in the heap).
  vector<Group*>  highestMatches;
  vector<Student>  highestStudentsCopy;

  // The vector that will temporarally hold matches.
  vector<Group*>  matches;

  // Initalize everything on the matches vector
  for(unsigned i=0; i<students.size() / 4; i++) {
    Group* tmp = new Group();
    matches.push_back(tmp);
  }

  // Start matching students to times
  int size = 0;
  match(students, matches, size, highestMatches, highestStudentsCopy);

  // highestMatches now contains a vector of all the teams, and size contains
  // many teams were made, so print all of those out.
  std::cout << std::endl << "TEAMS" << std::endl;
  for(unsigned i=0; i<highestMatches.size(); i++) {
    if(highestMatches.at(i)->getSize() == 4) {
      std::cout << highestMatches.at(i)->toString() << std::endl;
    }
  }

  // Print out any users who didn't make it into a team
  std::cout << std::endl << "UNASSIGNED STUDENTS" << std::endl;
  // Print any students who were in a group that wasn't full (haxish solution)
  for(unsigned i=0; i<highestMatches.size(); i++) {
    if(highestMatches.at(i)->getSize() != 4) {
      std::vector<Student> tmp = highestMatches.at(i)->getStudents();
      for(unsigned j=0; j<tmp.size(); j++) {
        std::cout << tmp.at(j).name << std::endl;
      }
    }
  }


  // Print any studnets from the student copy
  for(unsigned i=0; i<highestStudentsCopy.size(); i++) {
    if(highestStudentsCopy.at(i).isAvaliable()) {
      std::cout << students.at(i).name << std::endl;
    }
  }
  std::cout << std::endl;
}

bool Matcher::match(vector<Student>& students, 
                    vector<Group*>& matches, 
                    int& size, 
                    vector<Group*>& highestMatches,
                    vector<Student>& highestStudentsCopy) {
  // Break case, if all the students are matched.
  if(size + 1 == (students.size() / 4)) {
    int maxUnmatchedStudents = students.size() % 4;
    int numUnmatchedStudents = 0;
    for(unsigned i=0; i<students.size(); i++) {
      if(students.at(i).isAvaliable()) {
        numUnmatchedStudents++;
      }
    }

    if(numUnmatchedStudents == maxUnmatchedStudents) {
      highestMatches = matches;
      highestStudentsCopy = students;
      return true;
    }
  }

  // Get the target students already matched if any
  Group* group = NULL;
  if(matches.at(size)->isFull() == false) {
    group = matches.at(size);
  }
  else {
    size++;
    group = matches.at(size);
  }

  // Go through the rest of the students until you find one that matches.
  for(unsigned i=0; i<students.size(); i++) {
    Student& target = students.at(i);
    if(target.isAvaliable() && schedulesMatch(*group, target)) {
      // Make sure this student is no longer avaliable for a group
      target.isAvaliable(false);
      group->addStudent(target);

      // Recurse through this again.
      bool allMatched = match(students, matches, size, highestMatches, highestStudentsCopy);

      // If the break case was met, then return.
      if(allMatched == true) {
        return true;
      }
      else {
        target.isAvaliable(true);
        group->removeLastStudent();
      }
    }
  }

  // If we cannot match up any more students and have a new record for highest
  // number of students matched, save this set of matches and return to
  // backtrack and start looking for better sets of matches.
  if(matches.size() > highestMatches.size()) {
    // Perform a deep copy of everything
    highestMatches.clear();
    for(unsigned i=0; i<matches.size(); i++) {
      Group* original = matches.at(i);
      Group* copy = new Group(original);
      highestMatches.push_back(copy);
    }

    // Store the students at this point so that we can see which students were
    // not matched at this point in time.
    highestStudentsCopy.clear();
    for(unsigned i=0; i<students.size(); i++) {
      highestStudentsCopy.push_back(students.at(i));
    }
  }

  // If we created a new group (vector<student>) during this iteration, and we are
  // backtracking, then we need to remove this newly created vector<studemt> so that
  // our numbers of groups doesn't get schewed
  if(group->isEmpty()) {
    size--;
  }
  
  return false;
}


bool Matcher::schedulesMatch(Group group, Student student) {
  if(group.isEmpty()) {
    return true;
  }

  // All of the students alreday in the group
  vector<Student> students = group.getStudents();

  // The hours that this new student can meet
  vector<int> hours = student.getHours();

  // Check if the new students hours match at least 5 hours of the groups 
  // students
  for(unsigned i=0; i<students.size(); i++) {
    unsigned hoursPtr = 0;
    unsigned tmpHoursPtr = 0;
    vector<int> tmpHours = students.at(i).getHours();

    // Because the hours for each student is guarenteed to already be sorted,
    // we will only have to traverse each list of hours once.
    while(hoursPtr < hours.size() && tmpHoursPtr < tmpHours.size()) {
      if(hours.at(hoursPtr) > tmpHours.at(tmpHoursPtr)) {
        tmpHoursPtr++;
      }
      else if(hours.at(hoursPtr) < tmpHours.at(tmpHoursPtr)) {
        hours.erase(hours.begin() + hoursPtr);
      }
      else {
        tmpHoursPtr++;
        hoursPtr++;
      }
    }

    // Remove any left over hours from the students hours that don't work
    // with the groupds hours
    for(unsigned i=hoursPtr; i<hours.size(); i++) {
      hours.erase(hours.begin() + i);
    }
  }

  if(hours.size() < 5) {
    return false;
  }
  return true;
}
