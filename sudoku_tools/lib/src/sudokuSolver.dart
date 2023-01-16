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
  final lastCorrectIndex = <int>[-1];
  final addedIndices = List.generate(81,
          (index) =>
      (board[index] == 0) ? List.filled(0, 0, growable: true) : null,
      growable: false);

  int index = 0;
  while (index < 81) {
    if (board[index] != 0) {
      index++;
      continue; // Cell is already defined
    }
    final validMissingNumbers = getValidNumbersForIndex(index, board).where(
            (missingDigit) => !addedIndices[index]!.contains(missingDigit));

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
    // Cannot advance with a valid number
    if (lastCorrectIndex.last == -1) {
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