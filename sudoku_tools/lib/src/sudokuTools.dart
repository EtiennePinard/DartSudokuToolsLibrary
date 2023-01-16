/// Returns all the digits which are valid for that cell 
/// following the sudoku rules
Iterable<int> getValidNumbersForIndex(int index, List<int> board) {
  final List<int> missingBoxDigits = _getMissingBoxDigits(index, board);
  final List<int> missingRowDigits = _getMissingRowDigits(index, board);
  final List<int> missingColumnDigits = _getMissingColumnDigits(index, board);
  return missingBoxDigits.where((missingDigit) =>
  missingRowDigits.contains(missingDigit) &&
      missingColumnDigits.contains(missingDigit));
}

List<int> _getMissingBoxDigits(int index, List<int> board) {
  return _findMissingDigits(getBoxCells(cellBoxIndex(index)), board);
}

List<int> _getMissingRowDigits(int index, List<int> board) {
  return _findMissingDigits(getRowCells(index ~/ 9), board);
}

List<int> _getMissingColumnDigits(int index, List<int> board) {
  return _findMissingDigits(getColumnCells(index % 9), board);
}

/// Finds are the missing digits to complete a list which goes from 1 to 9
List<int> _findMissingDigits(List<int> indices, List<int> board) {
  final alreadySeenDigits = List.filled(10, false);
  for (final index in indices) {
    final value = board[index];
    if (!alreadySeenDigits[value]) {
      alreadySeenDigits[value] = true;
    }
  }
  final missingDigits = List.generate(9, (index) => index + 1);
  missingDigits.removeWhere((digit) => alreadySeenDigits[digit]);
  return missingDigits;
}

/// Return true if a sudoku is a valid sudoku else false
bool isSudokuCorrect(List<int> board, bool debug) {
  if (board.length != 81) {
    if (debug) {
      print('The board length, ${board.length}, is not equal to 81.');
    }
    return false;
  }
  for (int i = 0; i < 3; i++) {
    _isBoxRowCorrect(i, board, debug);
  }
  return true;
}

bool _isBoxRowCorrect(int boxRowIndex, List<int> board, bool debug) {
  for (int i = 0; i < 3; i++) {
    final index = boxRowIndex * 3 + i;
    if (!_doesListContainValidDigits(
        getBoxCells(index).map((e) => board[e]), "box", debug)) return false;

    if (!_doesListContainValidDigits(
        getRowCells(index).map((e) => board[e]), "row", debug)) return false;

    if (!_doesListContainValidDigits(
        getRowCells(index).map((e) => board[e]), "column", debug))
      return false;
  }
  return true;
}

bool _doesListContainValidDigits(
    Iterable<int> digits, String inWhat, bool debug) {
  if (digits.length != 9) return false;
  final alreadySeenDigits = List.filled(9, 0);
  for (int i = 0; i < digits.length; i++) {
    final digit = digits.elementAt(i);
    if (digit < 1 || digit > 9) {
      if (debug) print('Digit $digit is not between 1 or 9 in $inWhat');
      return false;
    }
    if (alreadySeenDigits.contains(digit)) {
      if (debug) print('Digit $digit is duplicated in $inWhat');
      return false;
    }
    alreadySeenDigits[i] = digit;
  }
  return true;
}

/// Return a list containing the index from smallest to largest of the box
/// specified by the box index parameter. <br>
/// The box index is a number from 0 to 8, where 0 is the top left box
/// box and 8 is the bottom right box.
List<int> getBoxCells(int boxIndex) {
  final digitsInBox =
  List<int>.generate(9, (int index) => -1, growable: false);
  final boxStartIndex = boxIndex ~/ 3 * 27 + boxIndex % 3 * 3;
  for (int x = 0; x < 9; x++) {
    // Loop every index in the box
    final cellIndex = x ~/ 3 * 9 + x % 3 + boxStartIndex;
    digitsInBox[x] = cellIndex;
  }
  return digitsInBox;
}

/// Return a list containing the index from smallest to largest of the row
/// specified by the row index parameter. <br>
/// The row index is a number from 0 to 8, where 0 is the top row  and 8 is the
/// bottom row.
List<int> getRowCells(int rowIndex) {
  final digitsInRow = List<int>.filled(9, -1);
  for (int x = 0; x < 9; x++) {
    // Loop every index in the row
    final cellIndex = rowIndex * 9 + x;
    digitsInRow[x] = cellIndex;
  }
  return digitsInRow;
}

/// Return a list containing the index from smallest to largest of the column
/// specified by the column index parameter. <br>
/// The column index is a number from 0 to 8, where 0 is the furthest left
/// column and 8 is the furthest right column.
List<int> getColumnCells(int columnIndex) {
  final digitsInRow =
  List<int>.generate(9, (int index) => -1, growable: false);
  for (int y = 0; y < 9; y++) {
    // Loop every index in the column
    final cellIndex = y * 9 + columnIndex;
    digitsInRow[y] = cellIndex;
  }
  return digitsInRow;
}

/// Returns the box index (number from 0 to 8) of the cell index.
int cellBoxIndex(int index) => index ~/ 3 % 3 + index ~/ 27 * 3;

/// Returns the string representation of a sudoku board.
String sudokuToString(List<int> board) {
  if (board.length != 81) {
    throw ArgumentError("The board length, which is ${board.length}, is not equal to 81.");
  }
  var string = "";
  for (int i = 0; i < 81; i++) {
    final digit = board[i] == 0 ? " " : board[i];
    string += "[$digit] ";
    if ((i + 1) % 3 == 0) string += "\t";
    if ((i + 1) % 9 == 0) string += "\n";
    if ((i + 1) % 27 == 0) string += "\n";
  }
  return string;
}