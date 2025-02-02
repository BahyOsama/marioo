import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marioo/button.dart';
import 'package:marioo/shrooms.dart';

import 'jumpingmario.dart';
import 'mario.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static double marioX = 0;
  static double marioY = 1;
  double marioSize = 50;
  double shroomX = 0.5;
  double shroomY = 1;
  double time = 0;
  double height = 0;
  double initialHeight = marioY;
  String direction = "right";
  bool midrun = false;
  bool midjump = false;
  var gameFont = GoogleFonts.pressStart2p(
      textStyle: TextStyle(color: Colors.white, fontSize: 20));
  static double blockX = -0.3;
  static double blockY = 0.3;
  double moneyX = blockX;
  double moneyY = blockY;
  int money = 0;
  // Box position and state
  static double boxX = 0.3;
  static double boxY = 0.3;

  // Coin position and state
  double coinX = boxX;
  double coinY = boxY + 0.2; // Position above the box

  // Coin state
  bool coinVisible = true;
  bool mushroomVisible = true;

  void checkIfAteShrooms() {
    if ((marioX - shroomX).abs() < 0.05 && (marioY - shroomY).abs() < 0.05) {
      setState(() {
        // if eaten, move the shrooms off the screen
        shroomX = 2;
        marioSize = 100;
        mushroomVisible = false;

        // After a delay, make the mushroom reappear
        Timer(Duration(seconds: 5), () {
          setState(() {
            shroomX = 0.5; // Set the mushroom back to a visible position
            shroomY = 1; // Adjust Y if needed
            mushroomVisible = true;
            // Make the mushroom visible again
          });
        });
      });
    }
  }

//SHOW ME THE MONEY
  void releaseMoney() {
    money++;
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        moneyY -= 0.1;
      });
      if (moneyY < -1) {
        timer.cancel();
        moneyY = blockY;
      }
    });
  }

  // FALL OFF THE PLATFORM
  void fall() {
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        marioY += 0.5;
      });
      if (marioY < 1) {
        marioY = 1;
        timer.cancel();
        midjump = false;
      }
    });
  }

  // CHECK IF MARIO IS ON THE PLATFORM
  bool onPlatform(double x, double y) {
    if ((x - blockX).abs() < 0.05 && (y - blockY).abs() < 0.3) {
      midjump = false;
      marioY = blockY - 0.28;
      return true;
    } else {
      return false;
    }
  }

  // Check if Mario collected the coin
  void checkCoinCollision() {
    if ((marioX - coinX).abs() < 0.05 && (marioY - coinY).abs() < 0.1) {
      setState(() {
        coinVisible = false;
        money++;
      });
    }
  }

  void preJump() {
    time = 0;
    initialHeight = marioY;
  }

  void jump() {
    // this first if statment disables the double jump
    if (midjump == false) {
      midjump = true;
      preJump();
      Timer.periodic(Duration(milliseconds: 50), (timer) {
        time += 0.05;
        height = -4.9 * time * time + 5 * time;

        if (initialHeight - height > 1) {
          midjump = false;

          setState(() {
            marioY = 1;
          });
          timer.cancel();
        } else {
          setState(() {
            marioY = initialHeight - height;
          });
        }
      });
    }
  }

  void moveRight() {
    direction = "right";
    checkIfAteShrooms();
    checkCoinCollision();

    Timer.periodic(Duration(milliseconds: 50), (timer) {
      checkIfAteShrooms();
      checkCoinCollision();
      if (MyButton().userIsHoldingButton() == true && (marioX + 0.02) < 1) {
        setState(() {
          marioX += 0.02;
          midrun = !midrun;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void moveLeft() {
    direction = "left";
    checkIfAteShrooms();
    checkCoinCollision();
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      checkIfAteShrooms();
      checkCoinCollision();
      if (MyButton().userIsHoldingButton() == true && (marioX - 0.02) > -1) {
        setState(() {
          marioX -= 0.02;
          midrun = !midrun;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Container(
                  color: Colors.blue,
                  child: AnimatedContainer(
                    alignment: Alignment(marioX, marioY),
                    duration: Duration(milliseconds: 0),
                    child: midjump
                        ? JumpingMario(
                            direction: direction,
                            size: marioSize,
                          )
                        : MyMario(
                            direction: direction,
                            midrun: midrun,
                            size: marioSize,
                          ),
                  ),
                ),
                if (mushroomVisible)
                  Container(
                    alignment: Alignment(shroomX, shroomY),
                    child: MyShroom(),
                  ),
                Container(
                  alignment: Alignment(boxX, boxY),
                  child: Image.asset(
                    "img/box.png",
                    width: 50,
                    height: 50,
                  ),
                ),
                if (coinVisible)
                  Container(
                    alignment: Alignment(coinX, coinY),
                    child: Image.asset(
                      "img/coins.png",
                      width: 30,
                      height: 30,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            "MARIO",
                            style: gameFont,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text("$money", style: gameFont)
                        ],
                      ),
                      Column(
                        children: [
                          Text("WORLD", style: gameFont),
                          SizedBox(
                            height: 10,
                          ),
                          Text("1-1", style: gameFont)
                        ],
                      ),
                      Column(
                        children: [
                          Text("TIME", style: gameFont),
                          SizedBox(
                            height: 10,
                          ),
                          Text("9999", style: gameFont)
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.brown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyButton(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    function: moveLeft,
                  ),
                  MyButton(
                    child: Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                    ),
                    function: jump,
                  ),
                  MyButton(
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    function: moveRight,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
