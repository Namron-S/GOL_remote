import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:game_of_life/model_world.dart';

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
  final WorldModel worldModel = new WorldModel();
  bool simulationOn = false;
  Timer timer;
  Size cellSize = Size(25, 25);

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
    this.cellSize = calcCellSize(context);
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
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
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
                child: Icon(Icons.forward),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 30, right: 30),
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
                child: Icon(Icons.clear),
              ),
            ),
          ),
          Container(
            width: 30,
            height: 30,
            child: FittedBox(
              child: FloatingActionButton(
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
            ),
          ),
        ],
      ),
    );
  }

  List<TableRow> getTableRows() {
    final List<TableRow> rows = <TableRow>[]..length = worldModel.noOfRows;
    for (int i = 0; i < worldModel.noOfRows; i++) {
      rows[i] = getTableRow(i);
    }
    return rows;
  }

  TableRow getTableRow(int i) {
    final List<Widget> row = <Widget>[]..length = worldModel.noOfColumns;
    for (int j = 0; j < worldModel.noOfColumns; j++) {
      row[j] = generateCell(i, j);
    }
    return TableRow(children: row);
  }

  Size calcCellSize(BuildContext ctx) {
    final double shortestSide = MediaQuery.of(ctx).size.shortestSide;
    final double cellLength = shortestSide / worldModel.noOfColumns;
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
