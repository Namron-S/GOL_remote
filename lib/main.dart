import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp(
    key: UniqueKey(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({required Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Game Of Life',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.cloud_circle)),
                  Tab(icon: Icon(Icons.info)),
                ],
              ),
              title: const Text('Game Of Life'),
            ),
            body: TabBarView(
              children: [
                MyHomePage(
                  key: UniqueKey(),
                ),
                createInfoText(context),
              ],
            ),
          )),
    );
  }
}

Widget createInfoText(var context) {
  return Center(
      child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 16.0),
        children: <TextSpan>[
          const TextSpan(
            text: 'About\n\n',
            style:
                TextStyle(fontSize: 20.0, decoration: TextDecoration.underline),
          ),
          const TextSpan(
            text:
                "This app simulates Conway's Game of Life. For the sake of simplicity  we have a finite grid of cells\n and the border-cells are always dead.\n\n",
          ),
          const TextSpan(
            text: 'Rules\n\n',
            style:
                TextStyle(fontSize: 20.0, decoration: TextDecoration.underline),
          ),
          const TextSpan(
            text:
                'The universe of the Game of Life is an infinite, two-dimensional orthogonal grid of square cells,\neach of which is in one of two possible states, alive or dead, (or populated and unpopulated, respectively).\nEvery cell interacts with its eight neighbours, which are the cells that are horizontally, vertically,\nor diagonally adjacent. At each step in time, the following transitions occur:\n',
          ),
          const TextSpan(
            text:
                '   1. Any live cell with fewer than two live neighbours dies, as if by underpopulation.\n',
          ),
          const TextSpan(
            text:
                '   2. Any live cell with two or three live neighbours lives on to the next generation.\n',
          ),
          const TextSpan(
            text:
                '   3. Any live cell with more than three live neighbours dies, as if by overpopulation.\n',
          ),
          const TextSpan(
            text:
                '   4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.\n',
          ),
          const TextSpan(
            text:
                'The initial pattern constitutes the seed of the system. The first generation is created by applying the above rules\nsimultaneously to every cell in the seed; births and deaths occur simultaneously, and the discrete moment at which this happens\nis sometimes called a tick. Each generation is a pure function of the preceding one. The rules continue to be applied\nrepeatedly to create further generations.\n',
          ),
          TextSpan(
              text: '(Source: Wikipedia)',
              style: TextStyle(
                  fontSize: 12, color: Colors.black.withOpacity(0.75))),
        ],
      ),
    ),
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    required Key key,
  }) : super(key: key);
  @override
  createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin {
  final WorldModel worldModel = WorldModel();
  bool simulationOn = false;
  late Timer timer;
  Size cellSize = const Size(25, 25);

  void handleTimeout(Timer timer) {
    setState(() {
      worldModel.nextGeneration();
      if (worldModel.allCellsDead()) {
        timer.cancel();
        simulationOn = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    cellSize = calcCellSize(context);
    return Scaffold(
      body: Center(
        child: Table(
          border: TableBorder.symmetric(
              outside: const BorderSide(width: 2, color: Colors.blue)),
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: getTableRows(),
        ),
      ),
      floatingActionButton: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 30,
            height: 30,
            child: FittedBox(
              child: FloatingActionButton(
                backgroundColor: simulationOn ? Colors.grey : Colors.blue,
                onPressed: simulationOn
                    ? null
                    : () => {
                          setState(() {
                            worldModel.nextGeneration();
                          })
                        },
                tooltip: 'Next Generation',
                child: const Icon(Icons.forward),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 30, right: 30),
            width: 30,
            height: 30,
            child: FittedBox(
              child: FloatingActionButton(
                backgroundColor: simulationOn ? Colors.grey : Colors.blue,
                onPressed: simulationOn
                    ? null
                    : () => {
                          setState(() {
                            worldModel.setAllCellsToFalse();
                          })
                        },
                tooltip: 'Kill all cells!',
                child: const Icon(Icons.clear),
              ),
            ),
          ),
          SizedBox(
            width: 30,
            height: 30,
            child: FittedBox(
              child: FloatingActionButton(
                tooltip: simulationOn ? 'Stop Simulation' : 'Run Simulation',
                onPressed: () {
                  setState(() {
                    if (!simulationOn) {
                      timer = Timer.periodic(
                          const Duration(milliseconds: 500), handleTimeout);
                    } else {
                      timer.cancel();
                    }
                    simulationOn = !simulationOn;
                  });
                },
                child: simulationOn
                    ? const Icon(Icons.stop)
                    : const Icon(Icons.play_arrow),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TableRow> getTableRows() {
    final rows = List<TableRow>.generate(
        WorldModel.noOfRows, (index) => getTableRow(index));
    return rows;
  }

  TableRow getTableRow(int i) {
    final row = List<Widget>.generate(
        WorldModel.noOfColumns, (index) => generateCell(i, index));

    return TableRow(children: row);
  }

  Size calcCellSize(BuildContext ctx) {
    final double shortestSide = MediaQuery.of(ctx).size.shortestSide;
    final double cellLength = shortestSide / WorldModel.noOfColumns;
    return Size(cellLength, cellLength);
  }

  Widget generateCell(int i, int j) {
    return GestureDetector(
      onTap: () {
        setState(() {
          worldModel.toggleCell(i, j);
        });
      },
      child: AnimatedContainer(
        width: cellSize.width,
        height: cellSize.height,
        margin: const EdgeInsets.all(1.0),
        duration: const Duration(milliseconds: 250),
        color: getCellColor(i, j),
        child: const Text(''),
      ),
    );
  }

  Color getCellColor(int i, int j) {
    if (i == 0 ||
        i == WorldModel.noOfRows - 1 ||
        j == 0 ||
        j == WorldModel.noOfColumns - 1)
      return Colors.blueGrey;
    else
      return worldModel.getCellValue(i, j) ? Colors.greenAccent : Colors.grey;
  }

  @override
  bool get wantKeepAlive => true;
}

class WorldModel {
  static const int noOfRows = 16;
  static const int noOfColumns = 25;

  List<List<bool>> _cellMatrixNextGen =
      List.generate(noOfRows, (i) => List.generate(noOfColumns, (i) => false));
  List<List<bool>> _cellMatrix =
      List.generate(noOfRows, (i) => List.generate(noOfColumns, (i) => false));

  //WorldModel() {}

  bool allCellsDead() {
    for (int i = 1; i < noOfRows - 1; i++) {
      for (int j = 1; j < noOfColumns - 1; j++) {
        if (_cellMatrix[i][j]) return false;
      }
    }
    return true;
  }

  void toggleCell(int i, int j) {
    //the border cells remain dead
    if (i == 0 || i == noOfRows - 1 || j == 0 || j == noOfColumns - 1) {
      return;
    } else {
      _cellMatrix[i][j] = !_cellMatrix[i][j];
    }
  }

  bool getCellValue(int i, int j) {
    return _cellMatrix[i][j];
  }

  void nextGeneration() {
    for (int i = 1; i < noOfRows - 1; i++) {
      for (int j = 1; j < noOfColumns - 1; j++) {
        if (_cellMatrix[i][j]) {
          if (willBeDead(i, j)) {
            _cellMatrixNextGen[i][j] = false;
          } else {
            _cellMatrixNextGen[i][j] = true;
          }
        } else {
          if (isAwakenToLife(i, j)) {
            _cellMatrixNextGen[i][j] = true;
          } else {
            _cellMatrixNextGen[i][j] = false;
          }
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
    if (noOfAliveNeighbours < 2 || noOfAliveNeighbours > 3) {
      return true;
    } else {
      return false;
    }
  }

  bool isAwakenToLife(int i, int j) {
    if (getNoOfAliveNeighbours(i, j) == 3) {
      return true;
    } else {
      return false;
    }
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
