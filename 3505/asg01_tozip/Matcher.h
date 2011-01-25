/**
 * Matcher
 *
 * CS 3505
 * Authors: Landon Gilber-Bland and Alex Clemmer
 * Date: Spring 2011
 *
 * Matches a vector of student objects together based on the times they can
 * meet, and prints the results.
 */

#ifndef __MATCHER_H_
#define __MATCHER_H_

#include <vector>

#include "Student.h"
#include "Group.h"

class Matcher {

public:
  /** 
   * @brief Matches students together based on the times they can meet and
   * prints out the results
   * 
   * @param students The students to match times with each other
   */
  static void match(std::vector<Student>& students);


  /** 
   * @brief Checks if a given student can meet with a group of students for
   * at least five hours
   *
   * Note that we have this as public for testing purposes. In reality this is
   * a helper method that should be private
   * 
   * @param group A Group object that we want to check times with.
   * @param student The student to check times with the group
   * 
   * @return true if every student can meet for at least 5 hours, false 
   * otherwise.
   */
  static bool schedulesMatch(Group group, Student student);

private:
  /** 
   * @brief Recurisivly matches students together into groups of 4 based on the
   * times they can meet.
   *
   * The break case is if every possible student has been match, with the 
   * exception of the remainder of students that don't evenly divide into
   * four groups. If every student has been mached, the break case is reached
   * and true is returned. Otherwise false is returned.
   * 
   * @param students The students we are matching together
   * @param matches A reference to a vector of student pointer. This is where
   * the current set of match students will be saved as we recursivly call this
   * method
   * @param size The current number of completed groups we have. This is used
   * to figure out what group we are currently trying to find a match for as 
   * well as backtracking through the groups during the recursion.
   * @param highestMatches A reference to a vector of student pointers. This 
   * contains the greatest set of matched students we can find
   * 
   * @return true if every possible group has been created, falsewise.
   */
  static bool match(std::vector<Student>& students, 
                    std::vector<Group*>& matches, 
                    int& size, 
                    std::vector<Group*>& highestMatches,
                    std::vector<Student>& highestStudentsCopy);
};

#endif
