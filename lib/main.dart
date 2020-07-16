import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
              bottom: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.cloud_circle)),
                  Tab(icon: Icon(Icons.info)),
                ],
              ),
              title: Text('Game Of Life'),
            ),
            body: TabBarView(
              children: [
                MyHomePage(),
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
        style: TextStyle(color: Colors.black, fontSize: 16.0),
        children: <TextSpan>[
          TextSpan(
            text: 'About\n\n',
            style:
                TextStyle(fontSize: 20.0, decoration: TextDecoration.underline),
          ),
          TextSpan(
            text:
                "This app simulates Conway's Game of Life. For the sake of simplicity  we have a finite grid of cells\n" +
                    "and the border-cells are always dead.\n\n",
          ),
          TextSpan(
            text: 'Rules\n\n',
            style:
                TextStyle(fontSize: 20.0, decoration: TextDecoration.underline),
          ),
          TextSpan(
            text: 'The universe of the Game of Life is an infinite, two-dimensional orthogonal grid of square cells,\n' +
                'each of which is in one of two possible states, alive or dead, (or populated and unpopulated, respectively).\n' +
                'Every cell interacts with its eight neighbours, which are the cells that are horizontally, vertically,\n' +
                'or diagonally adjacent. At each step in time, the following transitions occur:\n',
          ),
          TextSpan(
            text:
                '   1. Any live cell with fewer than two live neighbours dies, as if by underpopulation.\n',
          ),
          TextSpan(
            text:
                '   2. Any live cell with two or three live neighbours lives on to the next generation.\n',
          ),
          TextSpan(
            text:
                '   3. Any live cell with more than three live neighbours dies, as if by overpopulation.\n',
          ),
          TextSpan(
            text:
                '   4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.\n',
          ),
          TextSpan(
            text: 'The initial pattern constitutes the seed of the system. The first generation is created by applying the above rules\n' +
                'simultaneously to every cell in the seed; births and deaths occur simultaneously, and the discrete moment at which this happens\n' +
                'is sometimes called a tick. Each generation is a pure function of the preceding one. The rules continue to be applied\n' +
                'repeatedly to create further generations.\n',
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
  MyHomePage({
    Key key,
  }) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin {
  WorldModel worldModel = new WorldModel();
  bool simulationOn = false;
  Timer timer;

  void handleTimeout(Timer timer) {
    setState(() {
      worldModel.nextGeneration();
      if (worldModel.allCellsDead()) {
        timer.cancel();
        simulationOn = false;
      }
    });
  }

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Center(
        child: Table(
          border: TableBorder.symmetric(
              outside: BorderSide(width: 2, color: Colors.blue)),
          defaultColumnWidth: IntrinsicColumnWidth(),
          children: getTableRows(),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FloatingActionButton(
            backgroundColor: simulationOn ? Colors.grey : Colors.blue,
            onPressed: simulationOn
                ? null
                : () => {
                      setState(() {
                        worldModel.nextGeneration();
                      })
                    },
            tooltip: 'Next Generation',
            child: Icon(Icons.forward),
          ),
          FloatingActionButton(
            backgroundColor: simulationOn ? Colors.grey : Colors.blue,
            onPressed: simulationOn
                ? null
                : () => {
                      setState(() {
                        worldModel.setAllCellsToFalse();
                      })
                    },
            tooltip: 'Kill all cells!',
            child: Icon(Icons.clear),
          ),
          FloatingActionButton(
            tooltip: simulationOn ? 'Stop Simulation' : 'Run Simulation',
            onPressed: () {
              setState(() {
                if (!simulationOn) {
                  timer = Timer.periodic(
                      Duration(milliseconds: 500), handleTimeout);
                } else {
                  timer.cancel();
                }
                simulationOn = !simulationOn;
              });
            },
            child: simulationOn ? Icon(Icons.stop) : Icon(Icons.play_arrow),
          ),
        ],
      ),
    );
  }

  List<TableRow> getTableRows() {
    List<TableRow> rows = List(worldModel.noOfRows);
    for (int i = 0; i < worldModel.noOfRows; i++) {
      rows[i] = getTableRow(i);
    }
    return rows;
  }

  TableRow getTableRow(int i) {
    List<Widget> row = List(worldModel.noOfColumns);
    for (int j = 0; j < worldModel.noOfColumns; j++) {
      row[j] = generateCell(i, j);
    }
    return TableRow(children: row);
  }

  Widget generateCell(int i, j) {
    return GestureDetector(
      onTap: () {
        setState(() {
          worldModel.toggleCell(i, j);
        });
      },
      child: AnimatedContainer(
        width: 25.0,
        height: 25.0,
        margin: EdgeInsets.all(1.0),
        duration: Duration(milliseconds: 250),
        color: getCellColor(i, j),
        child: Text(''),
      ),
    );
  }

  Color getCellColor(int i, int j) {
    if (i == 0 ||
        i == worldModel.noOfRows - 1 ||
        j == 0 ||
        j == worldModel.noOfColumns - 1)
      return Colors.blueGrey;
    else
      return worldModel.getCellValue(i, j) ? Colors.greenAccent : Colors.grey;
  }

  @override
  bool get wantKeepAlive => true;
}

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
    List dummy = _cellMatrix;
    _cellMatrix = _cellMatrixNextGen;
    _cellMatrixNextGen = dummy;
  }

  bool willBeDead(int i, int j) {
    int noOfAliveNeighbours = getNoOfAliveNeighbours(i, j);
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
