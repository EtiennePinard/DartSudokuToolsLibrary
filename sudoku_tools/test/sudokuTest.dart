import 'dart:math';

import 'package:sudoku_tools/src/sudokuGenerator.dart';
import 'package:sudoku_tools/src/sudokuSolver.dart';
import 'package:sudoku_tools/src/sudokuTools.dart';

void main() {
  print('Testing perfect grid generation...');
  if (!testPerfectSudokuGridGeneration()) {
    print('ERROR: The generation of perfect sudoku boards did not work');
    throw Error();
  }
  print('No error found in perfect grid generation');

  print('Testing unfilled grid generation...');
  if (!testRandomUniqueSudokuGridGeneration()) {
    print('ERROR: The generation of unfilled unique solution sudoku boards did not work');
    throw Error();
  }
  print('No error found in unfilled grid generation');
  print('Everything is correct');
}

/// The generation of unfilled unique solution sudoku grid
/// requires the generation of a perfect grid and solving that
/// grid over and over. This means that this function does a pretty
/// extensive code coverage of the library.
bool testRandomUniqueSudokuGridGeneration() {
  final random = Random();
  for (int i = 0; i < 5; i++) {
    final validSudoku = generateRandomUniqueSolutionSudoku(random);
    if (!doesSudokuHaveAUniqueSolution(validSudoku)) {
      print(sudokuToString(validSudoku));
      return false;
    }
  }
  return true;
}

/// Testing the generation of perfect sudoku grid <br>
/// The function generates 2000 to maybe encounter
/// BAS and therefore test more of the code.
bool testPerfectSudokuGridGeneration() {
  final random = Random();
  for (int i = 0; i < 2000; i++) {
    try {
      generatePerfectGrid(true, random: random);
    } catch (error) {
      return false;
    }
  }
  return true;
}

/*
This is the first random valid sudoku grid which was generated on 11/01/2023!
[1] [ ] [ ] 	[ ] [ ] [ ] 	[ ] [3] [ ]
[ ] [5] [ ] 	[ ] [ ] [ ] 	[4] [ ] [2]
[ ] [ ] [ ] 	[ ] [8] [ ] 	[ ] [ ] [ ]

[4] [ ] [ ] 	[ ] [ ] [ ] 	[ ] [7] [ ]
[ ] [7] [ ] 	[1] [ ] [ ] 	[ ] [ ] [ ]
[ ] [9] [ ] 	[6] [ ] [ ] 	[8] [ ] [ ]

[2] [ ] [ ] 	[ ] [1] [ ] 	[9] [ ] [ ]
[ ] [ ] [ ] 	[3] [ ] [2] 	[6] [5] [ ]
[ ] [ ] [ ] 	[7] [ ] [5] 	[ ] [ ] [ ]


[1] [8] [9] 	[4] [2] [7] 	[5] [3] [6]
[7] [5] [3] 	[9] [6] [1] 	[4] [8] [2]
[6] [2] [4] 	[5] [8] [3] 	[7] [9] [1]

[4] [6] [1] 	[2] [5] [8] 	[3] [7] [9]
[5] [7] [8] 	[1] [3] [9] 	[2] [6] [4]
[3] [9] [2] 	[6] [7] [4] 	[8] [1] [5]

[2] [3] [5] 	[8] [1] [6] 	[9] [4] [7]
[9] [1] [7] 	[3] [4] [2] 	[6] [5] [8]
[8] [4] [6] 	[7] [9] [5] 	[1] [2] [3]
 */
