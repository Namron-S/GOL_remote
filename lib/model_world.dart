class WorldModel {
  final int noOfRows = 16;
  final int noOfColumns = 25;

  List<List<bool>> _cellMatrixNextGen;
  List<List<bool>> _cellMatrix;

  WorldModel() {
    _cellMatrixNextGen = List.generate(
        noOfRows, (i) => List.generate(noOfColumns, (i) => false));
    _cellMatrix = List.generate(
        noOfRows, (i) => List.generate(noOfColumns, (i) => false));
  }

  bool allCellsDead() {
    for (int i = 1; i < noOfRows - 1; i++)
      for (int j = 1; j < noOfColumns - 1; j++)
        if (_cellMatrix[i][j]) return false;
    return true;
  }

  void toggleCell(int i, int j) {
    //the border cells remain dead
    if (i == 0 || i == noOfRows - 1 || j == 0 || j == noOfColumns - 1)
      return;
    else
      _cellMatrix[i][j] = !_cellMatrix[i][j];
  }

  bool getCellValue(int i, int j) {
    return _cellMatrix[i][j];
  }

  void nextGeneration() {
    for (int i = 1; i < noOfRows - 1; i++) {
      for (int j = 1; j < noOfColumns - 1; j++) {
        if (_cellMatrix[i][j]) {
          if (willBeDead(i, j))
            _cellMatrixNextGen[i][j] = false;
          else
            _cellMatrixNextGen[i][j] = true;
        } else {
          if (isAwakenToLife(i, j))
            _cellMatrixNextGen[i][j] = true;
          else
            _cellMatrixNextGen[i][j] = false;
        }
      }
    }
    //Swapping Matrices
    final dummy = _cellMatrix;
    _cellMatrix = _cellMatrixNextGen;
    _cellMatrixNextGen = dummy;
  }

  bool willBeDead(int i, int j) {
    final int noOfAliveNeighbours = getNoOfAliveNeighbours(i, j);
    if (noOfAliveNeighbours < 2 || noOfAliveNeighbours > 3)
      return true;
    else
      return false;
  }

  bool isAwakenToLife(int i, int j) {
    if (getNoOfAliveNeighbours(i, j) == 3)
      return true;
    else
      return false;
  }

  int getNoOfAliveNeighbours(int i, int j) {
    int result = 0;

    if (_cellMatrix[i - 1][j - 1]) result++;
    if (_cellMatrix[i - 1][j]) result++;
    if (_cellMatrix[i - 1][j + 1]) result++;
    if (_cellMatrix[i][j - 1]) result++;
    if (_cellMatrix[i][j + 1]) result++;
    if (_cellMatrix[i + 1][j - 1]) result++;
    if (_cellMatrix[i + 1][j]) result++;
    if (_cellMatrix[i + 1][j + 1]) result++;

    return result;
  }

  void setAllCellsToFalse() {
    for (int i = 1; i < noOfRows - 1; i++) {
      for (int j = 1; j < noOfColumns - 1; j++) {
        _cellMatrix[i][j] = false;
        _cellMatrixNextGen[i][j] = false;
      }
    }
  }
}
