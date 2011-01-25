/**
 * Student.h
 * CS 3505
 * Authors: Landon Gilbert-Bland and Alex Clemmer
 *
 * Represents information about students and their
 * available times.
 */
#ifndef __STUDENT_H
#define __STUDENT_H

#include <string>
#include <vector>


class Student {
 public:
  // The name of this student   
	std::string name;

  // The level this student codes at
	std::string level;

  // The times this student can meet
	std::vector<int> times;

  // The prefered teammates that this student would like to work with (if any)
	std::vector<std::string> preferedTeammates;

  // A flag indicating if this student is alreay in a group or not
  bool avaliable;

  /**
   * Constructor
   *
   * Build an "empty student
   */
  Student() {
    this->name = "NOT KNOWN";
    this->level = "NOT KNOWN";
    avaliable = true;
  }

  /**
   * Function to string
   *
   * returns a string representation of the student
   */
	std::string toString();

  /**
   * Function parse line
   *
   * parses a line from the file
   */
  void parseLine(std::string line);

  
  /** 
   * @brief Changes the avaliable flag to the given boolean
   * 
   * @param b the boolean to change the avaliable flag to.
   */
  void isAvaliable(bool b);

  /** 
   * @brief Checks if this student is already in a group or not
   * 
   * @return true if this student is not already in a group, false otherwise
   */
  bool isAvaliable();

  /** 
   * @brief Returns a vector of integers (copy) that represents times this 
   * student is avaliable to meet
   * 
   * @return a vector of integers (copy) that represents times this 
   * student is avaliable to meet
   */
  std::vector<int> getHours();

  /** 
   * @brief Adds a time that this student can meet to the hours vector.
   *
   * This method will insure that the hours vector will be in sorted order 
   * from least to greatest.
   * 
   * @param time The time to add.
   */
  void addTime(int time);

  /** 
   * @brief Copy constructor
   */
  Student(const Student& p);

  /** 
   * @brief Assignment operator
   */
  Student& operator= (Student const& p) {
    name = p.name;
    level = p.level;
    times = p.times;
    preferedTeammates = p.preferedTeammates;
    avaliable = p.avaliable;
    return *this;
  }
};

#endif
