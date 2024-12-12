import 'package:alumni/compontents/button.dart';
// import 'package:alumni/compontents/question_content_small.dart';
import 'package:alumni/compontents/question_form.dart';
import 'package:alumni/pages/navigation_page.dart';
import 'package:alumni/services/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class QuestionsPage extends StatefulWidget {
  final Map userInformation;
  const QuestionsPage({
    super.key,
    required this.userInformation,
  });

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  late final TextEditingController question1Controller =
      TextEditingController();
  late final TextEditingController question2Controller =
      TextEditingController();
  late final TextEditingController question3Controller =
      TextEditingController();
  late final TextEditingController question4Controller =
      TextEditingController();
  late final TextEditingController question5Controller =
      TextEditingController();
  late final TextEditingController question6Controller =
      TextEditingController();
  // Question 2
  int stronglyAgree2 = 0;
  int agree2 = 0;
  int neutral2 = 0;
  int disagree2 = 0;
  int stronglyDisagree2 = 0;
  // Question 3
  int stronglyAgree3 = 0;
  int agree3 = 0;
  int neutral3 = 0;
  int disagree3 = 0;
  int stronglyDisagree3 = 0;
  // Question 5
  int stronglyAgree5 = 0;
  int agree5 = 0;
  int neutral5 = 0;
  int disagree5 = 0;
  int stronglyDisagree5 = 0;
  // Question 6
  int stronglyAgree6 = 0;
  int agree6 = 0;
  int neutral6 = 0;
  int disagree6 = 0;
  int stronglyDisagree6 = 0;
  late final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final Map information = widget.userInformation;
  late final FirestoreService alumni = FirestoreService();
  bool clickSubmit = false;

  final List<String> likertScaleAgree = [
    "Strongly agree",
    "Agree",
    "Neutral",
    "Disagree",
    "Strongly disagree",
  ];
  final List<String> durationBeforeEmployed = [
    "I had a job before my graduation",
    "Within a month",
    "2-3 months",
    "4-5 months",
    "6-7 months",
    "More than 7 months",
  ];

  bool isAdaptabilityChecked = false;
  bool isComputerLiteracyChecked = false;
  bool isCreativityChecked = false;
  bool isCriticalThinkingChecked = false;
  bool isFinancialIntelligenceChecked = false;
  bool isInterpersonalChecked = false;
  bool isIntrapersonalChecked = false;
  bool isLeadershipChecked = false;
  bool isTimeManagementChecked = false;

  int checkedCount = 0; // Initialize checkedCount for checkboxes

  // Function to check if more checkboxes can be checked
  bool _canCheckMore() {
    checkedCount = [
      isAdaptabilityChecked,
      isComputerLiteracyChecked,
      isCreativityChecked,
      isCriticalThinkingChecked,
      isFinancialIntelligenceChecked,
      isInterpersonalChecked,
      isIntrapersonalChecked,
      isLeadershipChecked,
      isTimeManagementChecked,
    ].where((checked) => checked).length;

    return checkedCount < 5;
  }

  List<String> setSearchParam(String firstName, String lastName) {
    String name = '$firstName $lastName';
    List<String> caseSearchList = [];
    String temp = '';

    for (int i = 0; i < name.length; i++) {
      temp += name[i];
      caseSearchList.add(temp.toLowerCase());
    }

    name = '$lastName $firstName';
    temp = '';
    for (int i = 0; i < name.length; i++) {
      temp += name[i];
      caseSearchList.add(temp.toLowerCase());
    }

    return caseSearchList;
  }

  Future<String> onSubmitAndValidate() async {
    final DocumentReference document = alumni.alumni.doc();
    final String documentID = document.id;

    // Set the new alumni document
    await _setAlumniDocument(document);

    // Update graduation year statistics
    await _updateYearStats();

    // Update employment statistics
    await _updateEmploymentStats();

    // Update question statistics
    await _updateQuestionStats('question_2', {
      'strongly_agree': stronglyAgree2,
      'agree': agree2,
      'neutral': neutral2,
      'disagree': disagree2,
      'strongly_disagree': stronglyDisagree2,
    });

    await _updateQuestionStats('question_3', {
      'strongly_agree': stronglyAgree3,
      'agree': agree3,
      'neutral': neutral3,
      'disagree': disagree3,
      'strongly_disagree': stronglyDisagree3,
    });

    await _updateQuestionStats('question_5', {
      'strongly_agree': stronglyAgree5,
      'agree': agree5,
      'neutral': neutral5,
      'disagree': disagree5,
      'strongly_disagree': stronglyDisagree5,
    });

    await _updateQuestionStats('question_6', {
      'strongly_agree': stronglyAgree6,
      'agree': agree6,
      'neutral': neutral6,
      'disagree': disagree6,
      'strongly_disagree': stronglyDisagree6,
    });

    return documentID;
  }

// Function to set the alumni document
  Future<void> _setAlumniDocument(DocumentReference document) async {
    await document.set({
      'email': information['email'],
      'first_name': information['first_name'],
      'last_name': information['last_name'],
      'degree': information['degree'],
      'year_graduated': information['year_graduated'],
      'sex': information['sex'],
      'employment_status': information['employment_status'],
      'middle_name': information['middle_name'],
      'date_of_birth': information['date_of_birth'],
      'occupation': information['occupation'],
      'searchable_name':
          setSearchParam(information['first_name'], information['last_name']),
      'question_1': question1Controller.text,
      'question_2': question2Controller.text,
      'question_3': question3Controller.text,
      'question_4': question4Controller.text,
      'question_5': question5Controller.text,
      'question_6': question6Controller.text,
    });
  }

// Function to update year-based statistics
  Future<void> _updateYearStats() async {
    try {
      final DocumentReference documentStats =
          alumni.stats.doc(information['year_graduated']);
      final DocumentSnapshot yearData = await documentStats.get();

      if (yearData.exists) {
        await documentStats.update({'value': yearData.get('value') + 1});
      } else {
        await documentStats.set({
          'value': 1,
          'year': int.parse(information['year_graduated']),
        });
      }
    } catch (e) {
      print('Error updating year stats: ${e}');
    }
  }

// Function to update employment statistics
  Future<void> _updateEmploymentStats() async {
    final employmentStatus = information['employment_status'].toLowerCase();
    final DocumentReference documentEmpStats =
        alumni.empStats.doc(information['year_graduated']);
    final DocumentSnapshot empStatsData = await documentEmpStats.get();

    Map<String, dynamic> updateData = {
      'year': int.parse(information['year_graduated']),
      'index': int.parse(information['year_graduated']) - 2001,
      'government_employed': 0,
      'privately_employed': 0,
      'self_employed': 0,
      'others': 0,
    };

    if (empStatsData.exists) {
      switch (employmentStatus) {
        case 'privately employed':
          updateData['privately_employed'] =
              empStatsData.get('privately_employed') + 1;
          break;
        case 'government employed':
          updateData['government_employed'] =
              empStatsData.get('government_employed') + 1;
          break;
        case 'self_employed':
          updateData['self_employed'] = empStatsData.get('self_employed') + 1;
          break;
        case 'others':
          updateData['others'] = empStatsData.get('others') + 1;
          break;
      }
      await documentEmpStats.update(updateData);
    } else {
      await documentEmpStats.set(updateData, SetOptions(merge: true));
    }
  }

// Function to update question statistics (for question_2, question_3, etc.)
  Future<void> _updateQuestionStats(
      String questionId, Map<String, int> stats) async {
    try {
      final DocumentReference collectionRef = FirebaseFirestore.instance
          .collection(questionId)
          .doc(information['degree']);
      final DocumentSnapshot qDoc = await collectionRef.get();

      collectionRef.update({
        'strongly_agree': qDoc.get('strongly_agree') + stats['strongly_agree'],
        'agree': qDoc.get('agree') + stats['agree'],
        'neutral': qDoc.get('neutral') + stats['neutral'],
        'disagree': qDoc.get('disagree') + stats['disagree'],
        'strongly_disagree':
            qDoc.get('strongly_disagree') + stats['strongly_disagree'],
      });
    } catch (e) {
      print('Error updating $questionId stats: ${e}');
    }
  }

  Widget CheckboxDesign(String label, bool value, Function(bool?) onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: value,
              onChanged: (bool? newValue) {
                if (newValue == true && !_canCheckMore()) {
                  // Don't allow more checks if already at 5
                  return;
                }
                onChanged(newValue);
              },
              mouseCursor: SystemMouseCursors.click,
              checkColor: Colors.white,
              fillColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const Color.fromRGBO(255, 210, 49, 1);
                }
                return Colors.grey.shade400;
              }),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth < 950;
    final bool isEmployed =
        information['employment_status'].toString().toLowerCase() != 'others';
    //width size: 950
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 210, 49, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 210, 49, 1),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topLeft,
                child: Text('OLOPSC Alumni Form'),
              ),
            ),
            SizedBox(
              width: 50,
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topRight,
                child: Text('OLOPSC Alumni Tracking System (OATS)'),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(

'https://lh3.googleusercontent.com/d/1A9nZdV4Y4kXErJlBOkahkpODE7EVhp1x'),
            alignment: Alignment.bottomLeft,
            scale: 2.5,
          ),
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  //olopsc logo // olopsc name
                  Image.network(

'https://lh3.googleusercontent.com/d/1DlDDvI0eIDivjwvCrngmyKp_Yr6d8oqH',
                      scale: 1.5),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text('Our Lady of Perpetual Succor College'),
                  const Text('Alumni Tracking System'),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //OCS Logo // Recognition & Credit
                      const Text('Made By: '),
                      Opacity(
                        opacity: 0.9,
                        child: Image.network(
                            //'https://lh3.googleusercontent.com/d/19U4DW6KMNsVOqT6ZzX_ikpezY2N24Vyi',
                            'https://lh3.googleusercontent.com/d/1VDWlFOEyS-rftjzmy1DtWYNf5HvDSDq3',
                            scale: 39.5),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  //larger screen
                  if (!isLargeScreen)
                    Column(
                      children: [
                        //1st Question
                        QuestionForm(
                          content: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    'What is your Life Skills? Choose atleast 3 with maximum of 5.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // First Column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CheckboxDesign(
                                            'Adaptability',
                                            isAdaptabilityChecked,
                                            (value) {
                                              if (value == true &&
                                                  !_canCheckMore()) return;
                                              setState(() =>
                                                  isAdaptabilityChecked =
                                                      value!);
                                            },
                                          ),
                                          CheckboxDesign(
                                            'Computer Literacy',
                                            isComputerLiteracyChecked,
                                            (value) {
                                              if (value == true &&
                                                  !_canCheckMore()) return;
                                              setState(() =>
                                                  isComputerLiteracyChecked =
                                                      value!);
                                            },
                                          ),
                                          CheckboxDesign(
                                            'Creativity',
                                            isCreativityChecked,
                                            (value) {
                                              if (value == true &&
                                                  !_canCheckMore()) return;
                                              setState(() =>
                                                  isCreativityChecked = value!);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Second Column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CheckboxDesign(
                                            'Critical Thinking',
                                            isCriticalThinkingChecked,
                                            (value) {
                                              if (value == true &&
                                                  !_canCheckMore()) return;
                                              setState(() =>
                                                  isCriticalThinkingChecked =
                                                      value!);
                                            },
                                          ),
                                          CheckboxDesign(
                                            'Financial Intelligence',
                                            isFinancialIntelligenceChecked,
                                            (value) {
                                              if (value == true &&
                                                  !_canCheckMore()) return;
                                              setState(() =>

                                                isFinancialIntelligenceChecked =
                                                      value!);
                                            },
                                          ),
                                          CheckboxDesign(
                                            'Interpersonal Skills',
                                            isInterpersonalChecked,
                                            (value) {
                                              if (value == true &&
                                                  !_canCheckMore()) return;
                                              setState(() =>
                                                  isInterpersonalChecked =
                                                      value!);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Third Column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CheckboxDesign(
                                            'Intrapersonal Skills',
                                            isIntrapersonalChecked,
                                            (value) {
                                              if (value == true &&
                                                  !_canCheckMore()) return;
                                              setState(() =>
                                                  isIntrapersonalChecked =
                                                      value!);
                                            },
                                          ),
                                          CheckboxDesign(
                                            'Leadership',
                                            isLeadershipChecked,
                                            (value) {
                                              if (value == true &&
                                                  !_canCheckMore()) return;
                                              setState(() =>
                                                  isLeadershipChecked = value!);
                                            },
                                          ),
                                          CheckboxDesign(
                                            'Time Management',
                                            isTimeManagementChecked,
                                            (value) {
                                              if (value == true &&
                                                  !_canCheckMore()) return;
                                              setState(() =>
                                                  isTimeManagementChecked =
                                                      value!);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (checkedCount < 3) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Please select at least 3 skills',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                if (checkedCount >= 5) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Maximum of 5 skills reached',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        //2nd Question
                        QuestionForm(
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    'The skills you\'ve mentioned helped you in pursuing your career path.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: 150,
                                  child: DropdownButtonFormField2(
                                    validator: (value) => value == null
                                        ? 'This field is required'
                                        : null,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    hint: const Text('Choose'),
                                    items: likertScaleAgree
                                        .map((item) => DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (String? value) {
                                      setState(() {
                                        question2Controller.text = value!;
                                        if (value == 'Strongly agree') {
                                          stronglyAgree2 = 1;
                                        } else if (value == 'Agree') {
                                          agree2 = 1;
                                        } else if (value == 'Neutral') {
                                          neutral2 = 1;
                                        } else if (value == 'Disagree') {
                                          disagree2 = 1;
                                        } else if (value ==
                                            'Strongly disagree') {
                                          stronglyDisagree2 = 1;
                                        }
                                      });
                                    },
                                    buttonStyleData: ButtonStyleData(
                                      height: 50,
                                      width: 160,
                                      padding: const EdgeInsets.only(
                                        left: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.black,
                                        ),
                                        color: Colors.white,
                                      ),
                                      elevation: 2,
                                    ),
                                    iconStyleData: const IconStyleData(
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black45,
                                      ),
                                      iconSize: 24,
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.white,
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //3rd Question
                        isEmployed
                            ? QuestionForm(
                                content: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          'Your first job aligns with your current job.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        width: 150,
                                        child: DropdownButtonFormField2(
                                          validator: (value) => value == null
                                              ? 'This field is required'
                                              : null,
                                          isExpanded: true,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 0, horizontal: 0),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                          hint: const Text('Choose'),
                                          items: likertScaleAgree
                                              .map((item) =>
                                                  DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(
                                                      item,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              question3Controller.text = value!;
                                              if (value == 'Strongly agree') {
                                                stronglyAgree3 = 1;
                                              } else if (value == 'Agree') {
                                                agree3 = 1;
                                              } else if (value == 'Neutral') {
                                                neutral3 = 1;
                                              } else if (value == 'Disagree') {
                                                disagree3 = 1;
                                              } else if (value ==
                                                  'Strongly disagree') {
                                                stronglyDisagree3 = 1;
                                              }
                                            });
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: 50,
                                            width: 160,
                                            padding: const EdgeInsets.only(
                                              left: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.black,
                                              ),
                                              color: Colors.white,
                                            ),
                                            elevation: 2,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black45,
                                            ),
                                            iconSize: 24,
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white,
                                            ),
                                          ),
                                          menuItemStyleData:
                                              const MenuItemStyleData(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        //4th Question
                        isEmployed
                            ? QuestionForm(
                                content: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          'How long does it take for you to land your first job after graduation?',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        width: 250,
                                        child: DropdownButtonFormField2(
                                          validator: (value) => value == null
                                              ? 'This field is required'
                                              : null,
                                          isExpanded: true,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 0, horizontal: 0),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                          hint: const Text('Choose'),
                                          items: durationBeforeEmployed
                                              .map((item) =>
                                                  DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(
                                                      item,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              question4Controller.text = value!;
                                              if (value == 'Strongly agree') {
                                                stronglyAgree5 = 1;
                                              } else if (value == 'Agree') {
                                                agree5 = 1;
                                              } else if (value == 'Neutral') {
                                                neutral5 = 1;
                                              } else if (value == 'Disagree') {
                                                disagree5 = 1;
                                              } else if (value ==
                                                  'Strongly disagree') {
                                                stronglyDisagree5 = 1;
                                              }
                                            });
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: 50,
                                            width: 160,
                                            padding: const EdgeInsets.only(
                                              left: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.black,
                                              ),
                                              color: Colors.white,
                                            ),
                                            elevation: 2,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black45,
                                            ),
                                            iconSize: 24,
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white,
                                            ),
                                          ),
                                          menuItemStyleData:
                                              const MenuItemStyleData(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        //5th Question
                        isEmployed
                            ? QuestionForm(
                                content: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          'The program you took in OLOPSC matches your current job.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        width: 150,
                                        child: DropdownButtonFormField2(
                                          validator: (value) => value == null
                                              ? 'This field is required'
                                              : null,
                                          isExpanded: true,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 0, horizontal: 0),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                          hint: const Text('Choose'),
                                          items: likertScaleAgree
                                              .map((item) =>
                                                  DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(
                                                      item,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              question5Controller.text = value!;
                                              if (value == 'Strongly agree') {
                                                stronglyAgree6 = 1;
                                              } else if (value == 'Agree') {
                                                agree6 = 1;
                                              } else if (value == 'Neutral') {
                                                neutral6 = 1;
                                              } else if (value == 'Disagree') {
                                                disagree6 = 1;
                                              } else if (value ==
                                                  'Strongly disagree') {
                                                stronglyDisagree6 = 1;
                                              }
                                            });
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: 50,
                                            width: 160,
                                            padding: const EdgeInsets.only(
                                              left: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.black,
                                              ),
                                              color: Colors.white,
                                            ),
                                            elevation: 2,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black45,
                                            ),
                                            iconSize: 24,
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white,
                                            ),
                                          ),
                                          menuItemStyleData:
                                              const MenuItemStyleData(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        //6th Question
                        isEmployed
                            ? QuestionForm(
                                content: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          'You are satisfied with your current job.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        width: 150,
                                        child: DropdownButtonFormField2(
                                          validator: (value) => value == null
                                              ? 'This field is required'
                                              : null,
                                          isExpanded: true,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 0, horizontal: 0),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                          hint: const Text('Choose'),
                                          items: likertScaleAgree
                                              .map((item) =>
                                                  DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(
                                                      item,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              question6Controller.text = value!;
                                            });
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: 50,
                                            width: 160,
                                            padding: const EdgeInsets.only(
                                              left: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.black,
                                              ),
                                              color: Colors.white,
                                            ),
                                            elevation: 2,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black45,
                                            ),
                                            iconSize: 24,
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white,
                                            ),
                                          ),
                                          menuItemStyleData:
                                              const MenuItemStyleData(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),

                        const SizedBox(height: 28),
                        Button(
                          enabled: !clickSubmit && checkedCount >= 2,
                          onSubmit: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                clickSubmit = true;
                              });
                              String documentID = await onSubmitAndValidate();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NavigationPage(
                                    docID: documentID,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget checkboxDesign(String label, bool value, Function(bool?) onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: value,
              onChanged: (bool? newValue) {
                if (newValue == true && !_canCheckMore()) {
                  // Don't allow more checks if already at 5
                  return;
                }
                onChanged(newValue);
              },
              mouseCursor: SystemMouseCursors.click,
              checkColor: Colors.white,
              fillColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const Color.fromRGBO(255, 210, 49, 1);
                }
                return Colors.grey.shade400;
              }),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
