# Dart Sudoku Tools Library
A library made in dart to aid in the solving of sudokus and the generation of valid sudoku boards with unique solutions.

## How to use the library in your project
Clone the repo and add this to your pubspec.yaml 
```yml
  sudoku_tools:
    path: # Path to the clone of this repository
```

## How to generate and solve sudoku
A sudoku is a list of integers of length 81 with digits 0 to 9.  
0 means that the cell is empty and all the other digits represents valid sudoku digits.  

```dart
import 'package:sudoku_tools/src/sudokuGenerator.dart';
import 'package:sudoku_tools/src/sudokuSolver.dart';
import 'package:sudoku_tools/src/sudokuTools.dart';

final validSudoku = generateRandomUniqueSolutionSudoku(Random()); // Generate a valid sudoku with a unique solution
backtrackSolveSudoku(validSudoku); // Solve the sudoku
print(sudokuToString(validSudoku)); // Print the sudoku in a friendly format
```
