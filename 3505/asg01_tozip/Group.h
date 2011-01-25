/**
 * Group.h
 * CS 3505
 * Authors: Landon Gilbert-Bland and Alex Clemmer
 *
 * Provides an abstraction for a 'group of students', ie a vector of students.
 * This allows us to just have a vector of groups, as well as methods that
 * more clearly state what we are doing with them.
 *
 * Besides that, this is basicly just a wrapper for a vector of students
 */
#ifndef __GROUP_H_
#define  __GROUP_H_

#include <vector>
#include <string>
#include "Student.h"

class Group {
public:
  // Creates a new group object from another one
  Group(Group* g) {
    std::vector<Student> studentsCopy = g->getStudents();
    for(unsigned i=0; i<studentsCopy.size(); i++) {
      students.push_back(studentsCopy.at(i));
    }
  }

  // Default constructor
  Group() {}


  /** 
   * @brief Checks if this group is full (ie has 4 students in it)
   * 
   * @return true if this groups is full, false otherwise.
   */
  bool isFull();

  /** 
   * @brief Checks if this group is empty (ie if it has no students in it).
   * 
   * @return true if this group is empty, false otherwise
   */
  bool isEmpty();

  /** 
   * @brief Removes the last student that was put into this group.
   */
  void removeLastStudent();

  /** 
   * @brief Adds a student into this group
   * 
   * @param s The student to add
   */
  void addStudent(Student s);

  /** 
   * @brief Returns the number of students in this group
   * 
   * @return the number of students in this group
   */
  int getSize();

  /** 
   * @brief Get a vector (copy) of all the students who are in this group.
   * 
   * @return A vector (copy) of all the students who are in this group
   */
  std::vector<Student> getStudents();
  
  /** 
   * @brief Create a string representation of this group.
   *
   * The string representation consists of the student name of every student
   * in this group
   * 
   * @return A string representation of this group.
   */
  std::string toString();


private:
  // Holds all the students that are in this group.
  std::vector<Student> students;
};
 
#endif
