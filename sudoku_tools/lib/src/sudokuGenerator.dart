import 'dart:math';

import 'sudokuSolver.dart';
import 'sudokuTools.dart';

/// This function is from the first answer of this stack overflow answer <br>
/// https://stackoverflow.com/questions/6924216/how-to-generate-sudoku-boards-with-unique-solutions
List<int> generateRandomUniqueSolutionSudoku(Random random) {
  final board = generatePerfectGrid(true, random: random);
  final indices = List.generate(81, (index) => index);
  indices.shuffle(random);
  for (final index in indices) {
    final value = board[index];
    board[index] = 0;
    final boardClone = List.generate(81, (index) => board[index]);
    if (!doesSudokuHaveAUniqueSolution(boardClone)) {
      board[index] = value;
    }
  }
  return board;
}

/// Using Mark Fredrick Graves, Jr. method to generate perfect grids called
/// the shrinking squares approach. <br> <br>
/// Explaining Video: https://www.youtube.com/watch?v=LHCHH5siBCg <br>
/// Java example: https://github.com/mfgravesjr/finished-projects/tree/master/SudokuGridGenerator
List<int> generatePerfectGrid(bool fillBoard,
    {Random? random, List<int>? definiteBoard}) {
  late final List<int> board;
  if (fillBoard) {
    if (random == null) {
      throw ArgumentError("The random parameter cannot be null if you are "
          "filling the board with random values!");
    }
    board = List.filled(81, 0);
    _randomlyCorrectlyFillEachBox(random, board);
  } else {
    if (definiteBoard == null) {
      throw ArgumentError(
          "The definiteBoard parameter cannot be null if you are "
          "not filling the board!");
    }
    board = definiteBoard;
  }

  final copy = List.generate(81, (index) => board[index], growable: false);
  final sortedIndices = List.filled(81, false);
  // Alternate between rows and column
  for (int directionIndex = 0; directionIndex < 9; directionIndex++) {
    for (var direction in _Direction.values) {
      if (_sortDirection(direction, directionIndex, sortedIndices, board)) {
        continue;
      }
      // Sorting is not successful! Time for Advance and Backtrack Sort
      // We need to backtrack and reset sorted cells through to the last iteration
      for (int i = 0; i < 9; i++) {
        // Resetting the previous row
        sortedIndices[(directionIndex - 1) * 9 + i] = false;
        // Resetting the previous column
        sortedIndices[directionIndex - 1 + i * 9] = false;
      }
      directionIndex -= 2; // Going back by 2 directions
    }
  }

  if (!isSudokuCorrect(board, true)) {
    print("ERROR: Imperfect grid generated!");
    print(sudokuToString(board));
    print(copy);
    throw Error();
  }
  return board;
}

void _randomlyCorrectlyFillEachBox(Random random, List<int> board) {
  final digits = List.generate(9, (index) => index + 1, growable: false);
  for (int i = 0; i < 27; i++) {
    if (i ~/ 3 * 3 % 9 != 0) {
      i = i ~/ 9 * 9 + 9;
      if (i >= 27) break;
    }
    digits.shuffle(random);
    // Go back to the first
    // This is works because we only iterate on the first row of each box
    final boxStartIndex = i ~/ 3 * 9 + i % 3 * 3;
    for (int boxIndex = 0; boxIndex < 9; boxIndex++) {
      var boardIndex = boxIndex ~/ 3 * 9 + boxIndex % 3 + boxStartIndex;
      board[boardIndex] = digits[boxIndex];
    }
  }
}

bool _sortDirection(_Direction direction, int directionIndex,
    List<bool> sortedIndices, List<int> board) {
  // The index are the numbers. The boolean tells us if the index
  // has been encountered in the row or column
  // 0 is left empty since there is no digit 0 in a sudoku board
  final encounteredDigits = List.filled(10, false);
  final indicesInDirection = List.filled(9, -1);
  for (int xOrYValue = 0; xOrYValue < 9; xOrYValue++) {
    final index = (direction == _Direction.ROW)
        ? directionIndex * 9 + xOrYValue
        : directionIndex + xOrYValue * 9;
    indicesInDirection[xOrYValue] = index;
    final digitBeingSorted = board[index];

    // Did we encounter this number?
    if (!encounteredDigits[digitBeingSorted]) {
      encounteredDigits[digitBeingSorted] = true;
      continue;
    }
    // This number is a duplicate!
    if (_boxAdjacentCellSwap(
        index, encounteredDigits, sortedIndices, direction, board)) {
      continue; // BAS Worked!
    }

    // BAS did not work with the first duplicate and so we
    // are trying it again with the second duplicate
    late final int firstDuplicateIndex;
    try {
      firstDuplicateIndex = indicesInDirection.firstWhere(
          (previousIndex) => board[previousIndex] == digitBeingSorted);
    } catch (error) {
      // Just for my sanity
      print(
          'The digit ${digitBeingSorted} at index $index is supposed to have a '
          'duplicate but it seems like it does not have one.');
      throw Error();
    }

    if (_boxAdjacentCellSwap(firstDuplicateIndex, encounteredDigits,
        sortedIndices, direction, board)) {
      continue; // BAS Worked for the second duplicate!
    }

    // BAS unfortunately did not work for the second digit and so we are at PAS
    if (_preferredAdjacentCellSwap(xOrYValue, encounteredDigits, direction,
        directionIndex, board[firstDuplicateIndex], board)) {
      continue; // PAS was successful were BAS was not, let's go!
    }
    // PAS was not successful, it is time to Advance and Backtrack Sort (ABS)
    return false;
  }
  // Registered these numbers as sorted
  indicesInDirection.forEach((index) {
    sortedIndices[index] = true;
  });
  return true;
}

bool _boxAdjacentCellSwap(
    int duplicateIndex,
    List<bool> digitsAlreadyInDirection,
    List<bool> sortedIndices,
    _Direction direction,
    List<int> board) {
  final boxCells = getBoxCells(cellBoxIndex(duplicateIndex));
  for (final potentialSwap in boxCells) {
    // Is the cell part of the current row or column being sorted
    if (direction == _Direction.COLUMN &&
        potentialSwap % 9 == duplicateIndex % 9) continue;
    if (direction == _Direction.ROW &&
        potentialSwap ~/ 9 == duplicateIndex ~/ 9) continue;
    // Was the potentialSwap already sorted
    if (sortedIndices[potentialSwap]) continue;
    // Is the number in that cell been encountered
    final potentialValue = board[potentialSwap];
    if (digitsAlreadyInDirection[potentialValue]) continue;
    // Is duplicate cell already been sorted
    if (sortedIndices[duplicateIndex]) {
      // Adjacent Cell Swap to not un-sort the already sorted column or row
      if (direction == _Direction.COLUMN &&
          potentialSwap ~/ 9 != duplicateIndex ~/ 9) continue;
      if (direction == _Direction.ROW &&
          potentialSwap % 9 != duplicateIndex % 9) continue;
    }
    // Finally swapping cells, either doing a box or adjacent cell swap
    final duplicateValue = board[duplicateIndex];
    board[duplicateIndex] = potentialValue;
    board[potentialSwap] = duplicateValue;
    digitsAlreadyInDirection[potentialValue] = true;
    return true;
  }
  return false;
}

// I was so tired with this algorithm, that I basically stole
// this code from the example algorithm in java. I will maybe rewrite
// this function but for now it works and I have better things to do
bool _preferredAdjacentCellSwap(
    int xOrYValueOfDupIndex,
    List<bool> digitsAlreadyInDirection,
    _Direction direction,
    int directionIndex,
    int duplicateValue,
    List<int> board) {
  // noting the location for the blindSwaps to prevent infinite loops.
  final blindSwapIndex = new List.filled(81, false);
  // loop of size 18 to prevent infinite loops as well. Max of 18 swaps are possible.
  // at the end of this loop, if continue or break statements are not reached, then
  // fail-safe is executed called Advance and Backtrack Sort (ABS) which allows the
  // algorithm to continue sorting the next row and column before coming back.
  // Somehow, this fail-safe ensures success.
  for (int counter = 0; counter < 18; counter++) {
    SWAP:
    for (int xOrYValue = 0; xOrYValue <= xOrYValueOfDupIndex; xOrYValue++) {
      int currentIndex = direction == _Direction.ROW
          ? directionIndex * 9 + xOrYValue
          : directionIndex + xOrYValue * 9;
      // Are we at the first duplicate index?
      if (board[currentIndex] != duplicateValue) {
        continue;
      }

      // So we always check in front of us
      int decrement = (direction == _Direction.ROW ? 9 : 1);

      // How far away you are from the top left corner of the box
      // 3 means that the row or column contains the top left corner
      // 0 means that the row or column contains the bottom right corner
      final flippedBoxDirectionIndex = 3 - (directionIndex % 3);

      // if you are in the first row / column of a box, you can swap with cells
      // that are in the next two rows (these rows are forward)
      for (int potentialSwap = 1;
          potentialSwap < flippedBoxDirectionIndex;
          potentialSwap++) {
        int adjacentCell = currentIndex +
            (direction == _Direction.ROW
                ? (potentialSwap + 1) * 9
                : potentialSwap + 1);

        // this creates the preference for swapping with unregistered numbers
        final swapIndexIsInTheBoard =
            (direction == _Direction.ROW && adjacentCell >= 81);

        final swapIndexIsNotTheFirstColumnOfTheBox =
            (direction == _Direction.COLUMN && adjacentCell % 9 == 0);
        // This condition can only happens in the first iteration of the loop
        // When the adjacent cell is the furthest away from the current index
        if (swapIndexIsInTheBoard || swapIndexIsNotTheFirstColumnOfTheBox) {
          // The furthest index is invalid, trying with the index closer to currentIndex
          adjacentCell -= decrement;
        } else {
          // Index is within the bound
          if (directionIndex % 3 != 0 || // Column or row is not at the beginning of a box
              potentialSwap != 1 || // We are at the second iteration of the loop
              blindSwapIndex[adjacentCell] || // We have already swapped the adjacent cell
              digitsAlreadyInDirection[board[adjacentCell]]) { // The digit is already in the row or column
            // Note: The last condition is what creates the preference for unregistered digits
            adjacentCell -= decrement;
          }
        }
        final adjacentNo = board[adjacentCell];

        // The index as already been swapped, so lets not waste time and just move on
        if (blindSwapIndex[adjacentCell]) {
          continue;
        }

        blindSwapIndex[adjacentCell] = true;
        board[currentIndex] = adjacentNo;
        board[adjacentCell] = duplicateValue;
        duplicateValue = adjacentNo;

        // Did we find a new digit in the row?
        if (digitsAlreadyInDirection[adjacentNo]) {
          // No, digit is already in direction, PAS was not successful
          // Trying again or just go to PAB
          break SWAP;
        }

        // Yes we did! PAS was successful!!!
        digitsAlreadyInDirection[adjacentNo] = true;
        return true;
      }
    }
  }
  return false;
}

enum _Direction {
  ROW,
  COLUMN;
}
