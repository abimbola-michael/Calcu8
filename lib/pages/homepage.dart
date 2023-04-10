import 'dart:async';
import 'dart:math';
import 'package:calcu8/extensions.dart';
import 'package:calcu8/models/calcinput.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/components.dart';
import '../utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String result = "";

  List<CalcInput> calculation = [];

  List<IconData> arrowIcons = [
    Icons.arrow_back,
    Icons.arrow_forward,
    // Icons.arrow_upward,
    // Icons.arrow_downward
  ];

  bool inverse = false;
  bool degree = true;
  bool allowDot = true;
  int opened_brackets = 0;
  String copiedAnswer = "";
  int currentPos = 0;
  ScrollController controller = ScrollController();
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    //  Timer.periodic(const Duration(seconds: 1), );
  }
  // void timerCallback(timer) {

  //   }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Calcul8"),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: List.generate(
              2,
              (index) {
                return IconButton(
                    onPressed: () {
                      if (index == 0) {
                        if (currentPos > 0) currentPos--;
                      } else if (index == 1) {
                        if (currentPos < calculation.length) currentPos++;
                      }
                      setState(() {});
                    },
                    icon: Icon(arrowIcons[index]));
              },
            )),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          currentPos = calculation.length;
                        });
                      },
                      child: ListView.builder(
                          controller: controller,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: calculation.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return currentPos == 0
                                  ? Container(
                                      alignment: Alignment.center,
                                      child: const CursorWidget(),
                                    )
                                  : Container();
                            } else {
                              final input = calculation[index - 1];
                              final input_string = input.input;
                              final isDigit = decimal.contains(input_string);
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CalcInputWidget(
                                    input.input,
                                    icon: input.icon,
                                    isDisplay: true,
                                    onTouch: () {
                                      setState(() {
                                        currentPos = index;
                                      });
                                    },
                                    onPressed: () {
                                      setState(() {
                                        currentPos = index;
                                      });
                                    },
                                  ),
                                  if (index == currentPos) ...[
                                    const CursorWidget()
                                  ]
                                ],
                              );
                            }
                          }),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: Text(
                      result,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
                child: GridView.builder(
                    // padding: const EdgeInsets.symmetric(vertical: 10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5),
                    itemCount: calc_inputs.length,
                    itemBuilder: (context, index) {
                      final input = calc_inputs[index];
                      final input_string = input.input;
                      if (input_string == "sin" || input_string == "sininv") {
                        input.input = inverse ? "sininv" : "sin";
                      } else if (input_string == "cos" ||
                          input_string == "cosinv") {
                        input.input = inverse ? "cosinv" : "cos";
                      } else if (input_string == "tan" ||
                          input_string == "taninv") {
                        input.input = inverse ? "taninv" : "tan";
                      }
                      if (input_string == "deg" || input_string == "rad") {
                        input.input = degree ? "deg" : "rad";
                      }

                      return CalcInputWidget(
                        input.input,
                        icon: input.icon,
                        onLongPressed: () {
                          if (input_string == "") {
                            setState(() {
                              result = "";
                              currentPos = 0;
                              calculation.clear();
                            });
                          }
                        },
                        onPressed: () {
                          try {
                            if (input.input == "inv") {
                              setState(() {
                                inverse = !inverse;
                              });
                              return;
                            }
                            if (input.input == "deg" || input.input == "rad") {
                              setState(() {
                                degree = !degree;
                              });
                              return;
                            }
                            if (input.input == "") {
                              if (calculation.isNotEmpty) {
                                if (currentPos > 0) {
                                  calculation.removeAt(currentPos - 1);
                                  currentPos--;
                                }
                              }
                            } else if (input.input == "C") {
                              currentPos = 0;
                              calculation.clear();
                            } else if (input.input == "=") {
                              calculation.clear();
                              calculation.addAll(toCalcInput(result));
                              currentPos = calculation.length;
                            } else if (input.input == "ans") {
                              calculation.insertAll(
                                  currentPos, toCalcInput(result));
                              currentPos = currentPos + result.length;
                            } else if (input.input == "cpans") {
                              if (result != "") {
                                copiedAnswer = result;
                              }
                            } else if (input.input == "psans") {
                              if (copiedAnswer != "") {
                                calculation.insertAll(
                                    currentPos, toCalcInput(copiedAnswer));
                                currentPos = currentPos + copiedAnswer.length;
                              }
                            } else {
                              if (input.input == ")" && opened_brackets == 0) {
                                return;
                              }
                              if (calculation.isNotEmpty) {
                                final lastCalcInput =
                                    calculation[currentPos - 1];
                                final lastInputString = lastCalcInput.input;
                                if ((arithmetic.contains(input_string) &&
                                        arithmetic.contains(lastInputString)) ||
                                    (scientific.contains(input_string) &&
                                        scientific.contains(lastInputString)) ||
                                    (others.contains(input_string) &&
                                        others.contains(lastInputString))) {
                                  calculation.removeLast();
                                  currentPos--;
                                }
                              }
                              if (input.input == ".") {
                                if (currentPos == 0 ||
                                    !decimal.contains(
                                        calculation[currentPos - 1].input)) {
                                  calculation.insert(
                                      currentPos - 1, CalcInput(input: "0"));
                                  currentPos++;
                                } else if (checkIfHasDot()) {
                                  print("hasnot = $currentPos");

                                  return;
                                }
                              }

                              calculation.insert(currentPos, input);
                              currentPos++;

                              if (currentPos != 0) {
                                controller.animateTo((currentPos).toDouble(),
                                    duration: const Duration(milliseconds: 100),
                                    curve: Curves.easeIn);
                              }
                            }
                            result = calculate(calculation);

                            setState(() {});
                          } on FormatException {}
                        },
                      );
                    }))
          ],
        ));
  }

  double factorial(double value) {
    if (value <= 1) return 1;
    return value * factorial(value - 1);
  }

  double root(double value, int exponent) {
    int i = 0;
    double result = 0;
    while (pow(i, exponent) < value) {
      i++;
    }
    if (pow(i, exponent) == value) {
      result = i.toDouble();
    } else {
      final prev = pow(i - 1, exponent);
      final next = pow(i, exponent);
      final diff = next - value;
      final real_diff = next - prev;
      result = i - 1 + (diff / real_diff);
    }
    return result;
  }

  // double root(double value, int exponent) {
  //   double result = 0;
  //   double start = 0;
  //   double end = value;
  //   double mid = (start + end) / 2;
  //   while (pow(mid, exponent) != value) {
  //     double mid = (start + end) / 2;
  //     final power = pow(mid, exponent);
  //     if (power < value) {
  //       start = mid;
  //     } else if (power > value) {
  //       end = mid;
  //     }
  //   }
  //   return result;
  // }
  List<CalcInput> toCalcInput(String string) {
    List<CalcInput> inputs = [];
    if (string != "") {
      for (int i = 0; i < string.length; i++) {
        final char = string[i];
        inputs.add(CalcInput(input: char));
      }
    }
    return inputs;
  }

  bool checkIfHasDot() {
    bool has = false;
    int pos = currentPos - 1;
    while (decimal.contains(calculation[pos].input) &&
        pos < calculation.length - 1) {
      if (calculation[pos].input == ".") {
        has = true;
        break;
      }
      pos--;
    }
    return has;
  }

  String calculate(List<CalcInput> calculation) {
    bool showResult = false;
    double result = 1;
    double value = 1;
    double prevValue = 1;
    String resultString = "";
    String string = "";
    String prevString = "";
    String arit = "";
    String sci = "";
    String other = "";
    int opened_brackets = 0;
    List<CalcInput> brackets_cals = [];
    print("cal_inputs = $calculation");

    void calc(int i) {
      //opened_brackets > 0 ||

      double value = string == ""
          ? arit == "x" || arit == "/" || arit == ""
              ? 1
              : 0
          : double.parse(string);
      double prevValue = prevString == ""
          ? arit == "x" || arit == "/" || arit == ""
              ? 1
              : 0
          : double.parse(prevString);
      if (scientific.contains(calculation[i].input) ||
          //calculation[i].input == "(" ||
          (i != calculation.length - 1 &&
              (opened_brackets > 0 ||
                  calculation[i + 1].input == "(" ||
                  decimal.contains(calculation[i + 1].input) ||
                  others.contains(calculation[i + 1].input) ||
                  scientific.contains(calculation[i + 1].input)))) {
        // sci = "";
        // if (calculation[i].input == "(" && opened_brackets == 1) {
        //   result = value;
        // }

        return;
      }

      // double value = string == "" ? 0 : double.parse(string);
      // double prevValue = prevString == "" ? 0 : double.parse(prevString);

      if (other != "") {
        if (prevString == "") {
          prevValue = 1;
        }
        if (other == "%") {
          value = prevValue / 100;
        } else if (other == "pi") {
          value = prevValue * pi;
        } else if (other == "!") {
          value = factorial(prevValue);
        } else if (other == "sq") {
          value = pow(prevValue, 2).toDouble();
        } else if (other == "cb") {
          value = pow(prevValue, 3).toDouble();
        }
        other = "";
      }
      if (sci != "") {
        if (prevString == "") {
          prevValue = 1;
        }
        if (sci == "sin") {
          value = prevValue * sin(degree ? value.toDouble().toRadians : value);
        } else if (sci == "sininv") {
          value = prevValue * asin(value);
          value = degree ? value.toDouble().toDegrees : value;
        } else if (sci == "cos") {
          value = prevValue * cos(degree ? value.toDouble().toRadians : value);
        } else if (sci == "cosinv") {
          value = prevValue * acos(value);
          value = degree ? value.toDouble().toDegrees : value;
        } else if (sci == "tan") {
          value = prevValue * tan(degree ? value.toDouble().toRadians : value);
        } else if (sci == "taninv") {
          value = prevValue * atan(value);
          value = degree ? value.toDouble().toDegrees : value;
        } else if (sci == "log") {
          value = prevValue * log(value);
        } else if (sci == "ln") {
          value = prevValue * ln2 * value;
        } else if (sci == "sqrt") {
          value = prevValue * sqrt(value);
        } else if (sci == "cbrt") {
          value = prevValue * root(value, 3);
        } else if (sci == "pow") {
          value = pow(prevValue, value).toDouble();
        } else if (sci == "rt") {
          value = root(value, prevValue.toInt()).toDouble();
        } else if (sci == "mod") {
          value = (prevValue % value);
        } else if (sci == "e") {
          value = prevValue * pow(10, value).toDouble();
        }
      }
      print("string = $string, prevString = $prevString");

      if (brackets_cals.isNotEmpty) {
        if (prevString == "") {
          prevValue = 1;
        }
        String bracket_result_string = calculate(brackets_cals);
        if (bracket_result_string != "") {
          value = prevValue * double.parse(bracket_result_string);
        }
        brackets_cals.clear();
        print(
            "bracket_result_string = $bracket_result_string, prevValue = $prevValue, value = $value, result = $result");
      }

      if (arit != "") {
        if (arit == "+") {
          result += value;
        } else if (arit == "-") {
          result -= value;
        } else if (arit == "x") {
          result *= value;
        } else if (arit == "/") {
          result /= value;
        }
      } else {
        result = value;
      }
    }

    if (calculation.isNotEmpty) {
      for (int i = 0; i < calculation.length; i++) {
        final calc_input = calculation[i];
        final input = calc_input.input;
        bool isDigit = false;
        bool isScientific = false;
        bool isOthers = false;
        bool isArithmetic = false;
        isDigit = decimal.contains(input);
        if (!isDigit) {
          isArithmetic = arithmetic.contains(input);
          if (!isArithmetic) {
            isScientific = scientific.contains(input);
            if (!isScientific) {
              isOthers = others.contains(input);
            }
          }
        }

        if (isDigit) {
          if (opened_brackets > 0) {
            brackets_cals.add(calc_input);
          }
          if (!showResult) showResult = true;
          if (opened_brackets == 0) string += input;
          calc(i);
        } else {
          if (opened_brackets == 0) {
            prevString = string;
            if (input != "(") {
              string = "";
            }
          }
          if (input == "(") {
            opened_brackets++;
          } else if (input == ")") {
            if (opened_brackets > 0) opened_brackets--;
          } else if (isOthers) {
            if (opened_brackets == 0) {
              other = input;
            }
          } else if (isArithmetic) {
            if (opened_brackets == 0) {
              arit = input;
            }
          } else if (isScientific) {
            if (opened_brackets == 0) {
              sci = input;
            }
          }

          if ((opened_brackets == 1 && input != "(") || opened_brackets > 1) {
            brackets_cals.add(calc_input);
          }
          calc(i);
        }
      }
      this.opened_brackets = opened_brackets;
      final string_value = result.toString();

      resultString = !showResult
          ? ""
          : string_value.endsWith(".0")
              ? string_value.substring(0, string_value.length - 2)
              : string_value;
    }
    return resultString;
  }
}
