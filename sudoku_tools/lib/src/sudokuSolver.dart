import 'sudokuTools.dart';

/// Checks if a sudoku have one unique solution using a backtrack solver.
/// This function does not modify the board parameter
bool doesSudokuHaveAUniqueSolution(List<int> board) {
  // So that we don't mutate the board
  final newBoard = List.generate(81, (index) => board[index]);
  for (int index = 0; index < 81; index++) {
    if (newBoard[index] != 0) {
      index++;
      continue; // Cell is already defined
    }
    var valueWhichProduceSolution = -1;
    final validValuesToTry = getValidNumbersForIndex(index, newBoard);

    for (final value in validValuesToTry) {
      newBoard[index] = value;
      final boardClone = List.generate(81, (index) => newBoard[index]);

      if (backtrackSolveSudoku(boardClone)) {
        if (valueWhichProduceSolution == -1) {
          valueWhichProduceSolution = value;
        } else {
          // There is already one value which solve it, so the sudoku has two solutions
          return false;
        }
      }

    }

    if (valueWhichProduceSolution == -1) {
      print('The sudoku does not have a valid solution!');
      throw Error();
    }
    newBoard[index] = valueWhichProduceSolution;
  }
  return true;
}

/// This function solves the board parameter.
/// Returns true if the sudoku is solvable else false.
bool backtrackSolveSudoku(List<int> board) {
  // This is a list of the square indices for which we tried values
  final lastCorrectIndex = <int>[-1];

  // List of indices that we tried for each square which is not defined
  final addedIndices = List.generate(81,
          (index) =>
      (board[index] == 0) ? List.filled(0, 0, growable: true) : null,
      growable: false);

  int index = 0;
  while (index < 81) {

    // if cell is already defined
    if (board[index] != 0) {
      index++;
      continue;
    }

    // Here we want all the valid numbers which could go in that square
    // and that we did not try yet
    final validMissingNumbers = getValidNumbersForIndex(index, board).where(
            (missingDigit) => !addedIndices[index]!.contains(missingDigit));

    // There is a valid number that can go in the current square,
    // therefore, we can advance to the next one
    if (validMissingNumbers.isNotEmpty) {
      // Using index 0 since it is faster than picking a random missing digit
      final validValue = validMissingNumbers.elementAt(0);
      board[index] = validValue;
      // Guaranteed not null since of the check at the start of the loop
      addedIndices[index]!.add(validValue);
      lastCorrectIndex.add(index);
      index++;
      continue;
    }
    // Unfortunately, we cannot advance further because there is no valid
    // numbers which can go into a square.Therefore we have to check
    // if we are back at the beginning (meaning we can't solve this board)
    // or we backtrack one index and we try it with another number.

    // We have backtracked to the beginning.
    // This means that we cannot solve this sudoku using our methods
    final bool areWeBackToTheBeginning = (lastCorrectIndex.last == -1);
    if (areWeBackToTheBeginning) {
      return false;
    }

    index = lastCorrectIndex.last;
    lastCorrectIndex.removeLast(); // Popping the last index from the "stack"
    // Clear the indices in front of the lastCorrectIndex
    for (int i = index; i < 81; i++) {
      final list = addedIndices[i];
      if (list == null) continue;
      board[i] = 0;
      if (i != index) list.clear();
    }
  }
  return true;
}