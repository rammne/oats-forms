import 'package:alumni/pages/navigation_page.dart';
import 'package:alumni/services/firebase.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlumniTrackingForm extends StatefulWidget {
  final Map<String, dynamic> userInformation;

  const AlumniTrackingForm({
    Key? key,
    required this.userInformation,
  }) : super(key: key);

  @override
  _AlumniTrackingFormState createState() => _AlumniTrackingFormState();
}

class _AlumniTrackingFormState extends State<AlumniTrackingForm> {
  // Constants
  static const _kMaxSkillSelections = 5;
  static const _kMinSkillSelections = 3;
  static const _kPrimaryColor = Color.fromARGB(255, 253, 216, 83);

  // Form Controllers
  late Map<String, TextEditingController> _questionControllers;

  // Alumni reference
  final FirestoreService alumni = FirestoreService();

  // Alumni Inputs
  late final Map information;

  // Alumni Skills
  final List<String> _alumniSkills = [];

  // Skills Selection
  final Map<String, bool> _skillsMap = {
    'Adaptability': false,
    'Computer Literacy': false,
    'Creativity': false,
    'Critical Thinking': false,
    'Financial Intelligence': false,
    'Interpersonal Skills': false,
    'Intrapersonal Skills': false,
    'Leadership': false,
    'Time Management': false,
  };

  final List<String> _likertScaleOptions = [
    'Strongly Agree',
    'Agree',
    'Neutral',
    'Disagree',
    'Strongly Disagree',
  ];

  final List<String> _employmentDurationOptions = [
    'Had job before graduation',
    'Within a month',
    '2-3 months',
    '4-5 months',
    '6-7 months',
    'More than 7 months',
  ];

  bool _isSubmitting = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If userInformation is empty, try to get from ModalRoute
    if (widget.userInformation.isEmpty &&
        ModalRoute.of(context)?.settings.arguments != null) {
      information =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    } else {
      information = widget.userInformation;
    }
    // Ensure name fields are present in information
    if (!information.containsKey('first_name') &&
        information.containsKey('firstName')) {
      information['first_name'] = information['firstName'];
    }
    if (!information.containsKey('middle_name') &&
        information.containsKey('middleName')) {
      information['middle_name'] = information['middleName'];
    }
    if (!information.containsKey('last_name') &&
        information.containsKey('lastName')) {
      information['last_name'] = information['lastName'];
    }
  }

  double _getFormWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return screenWidth * 0.4; // 40% of screen width for large screens
    } else if (screenWidth > 600) {
      return screenWidth * 0.6; // 60% of screen width for medium screens
    }
    return screenWidth * 0.9; // 90% of screen width for small screens
  }

  void _initializeControllers() {
    _questionControllers = {
      'skill_impact': TextEditingController(),
      'job_alignment': TextEditingController(),
      'employment_duration': TextEditingController(),
      'program_match': TextEditingController(),
      'job_satisfaction': TextEditingController(),
    };
  }

  int get _selectedSkillsCount =>
      _skillsMap.values.where((selected) => selected).length;

  bool get _canSelectMoreSkills => _selectedSkillsCount < _kMaxSkillSelections;

  void _toggleSkillSelection(String skill, bool? value) {
    if (value == true && !_canSelectMoreSkills) return;

    setState(() {
      _skillsMap[skill] = value ?? false;
    });
  }

  Widget _buildSkillsSelection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double chipSpacing = constraints.maxWidth > 600 ? 10 : 8;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Your Life Skills ($_selectedSkillsCount/$_kMaxSkillSelections)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: chipSpacing,
              runSpacing: chipSpacing,
              children: _skillsMap.keys.map((skill) {
                return FilterChip(
                  label: Text(
                    skill,
                    style: TextStyle(
                      fontSize: constraints.maxWidth > 600 ? 14 : 12,
                    ),
                  ),
                  selected: _skillsMap[skill]!,
                  onSelected: (selected) =>
                      _toggleSkillSelection(skill, selected),
                  selectedColor: _kPrimaryColor.withOpacity(0.3),
                  checkmarkColor: const Color.fromRGBO(11, 10, 95, 1),
                );
              }).toList(),
            ),
            if (_selectedSkillsCount < _kMinSkillSelections)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Please select at least $_kMinSkillSelections skills',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: constraints.maxWidth > 600 ? 12 : 10,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDropdownQuestion({
    required String title,
    required String controllerKey,
    required List<String> options,
    bool Function(String?)? onChanged,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double dropdownWidth =
            constraints.maxWidth > 600 ? 450 : constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: constraints.maxWidth > 600 ? 14 : 12,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: dropdownWidth,
              child: DropdownButtonFormField2<String>(
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                hint: Text(
                  'Select an option',
                  style: TextStyle(
                    fontSize: constraints.maxWidth > 600 ? 14 : 12,
                  ),
                ),
                items: options
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: constraints.maxWidth > 600 ? 14 : 12,
                            ),
                          ),
                        ))
                    .toList(),
                validator: (value) =>
                    value == null ? 'Please select an option' : null,
                onChanged: (value) {
                  if (onChanged != null) {
                    onChanged(value);
                  }
                  _questionControllers[controllerKey]?.text = value ?? '';
                },
                buttonStyleData: ButtonStyleData(
                  height: constraints.maxWidth > 600 ? 50 : 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper to increment per-program answer counts for each question
  Future<void> _incrementQuestionResponse({
    required String questionCollection,
    required String program,
    required String answer,
  }) async {
    final docRef = FirebaseFirestore.instance.collection(questionCollection).doc(program);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      Map<String, dynamic> data = snapshot.exists ? snapshot.data() as Map<String, dynamic> : {};
      // For question_1, initialize all skills to 0 if document does not exist
      if (questionCollection == 'question_1' && !snapshot.exists) {
        for (final skill in _skillsMap.keys) {
          data[skill] = 0;
        }
      }
      final updatedData = Map<String, int>.from(data.map((k, v) => MapEntry(k, v is int ? v : 0)));
      updatedData[answer] = (updatedData[answer] ?? 0) + 1;
      transaction.set(docRef, updatedData, SetOptions(merge: true));
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final DocumentReference document = alumni.alumni.doc();
      final String documentID = document.id;

      _skillsMap.forEach(
        (key, value) {
          if (value) {
            _alumniSkills.add(key);
          }
        },
      );

      await _setAlumniDocument(document);
      await _updateYearStats();

      final program = information['degree'];

      // Q1: For each selected skill, increment the count for that skill in the program document
      for (final skill in _alumniSkills) {
        await _incrementQuestionResponse(
          questionCollection: 'question_1',
          program: program,
          answer: skill,
        );
      }

      // Q2
      await _incrementQuestionResponse(
        questionCollection: 'question_2',
        program: program,
        answer: _questionControllers['skill_impact']!.text,
      );

      // Q3
      await _incrementQuestionResponse(
        questionCollection: 'question_3',
        program: program,
        answer: _questionControllers['job_alignment']!.text,
      );

      // Q5
      await _incrementQuestionResponse(
        questionCollection: 'question_5',
        program: program,
        answer: _questionControllers['program_match']!.text,
      );

      // Q6
      await _incrementQuestionResponse(
        questionCollection: 'question_6',
        program: program,
        answer: _questionControllers['job_satisfaction']!.text,
      );

      Navigator.pushReplacementNamed(
        context,
        'profile',
        arguments: documentID,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
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

  // Function to set the alumni document
  Future<void> _setAlumniDocument(DocumentReference document) async {
    await document.set({
      'alumni_id': information['alumni_id'], // <-- Ensure alumni_id is saved
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
      'question_1': _alumniSkills,
      'question_2': _questionControllers['skill_impact']!.text,
      'question_3': _questionControllers['job_alignment']!.text,
      'question_4': _questionControllers['employment_duration']!.text,
      'question_5': _questionControllers['program_match']!.text,
      'question_6': _questionControllers['job_satisfaction']!.text,
    });
    print('success1');
  }

  // Function to update year-based statistics
  Future<void> _updateYearStats() async {
    try {
      final DocumentReference documentStats =
          alumni.stats.doc(information['year_graduated']);
      final DocumentSnapshot yearData = await documentStats.get();

      if (yearData.exists) {
        await documentStats.update({'value': yearData.get('value') + 1});
        print('success2');
      } else {
        await documentStats.set({
          'value': 1,
          'year': int.parse(information['year_graduated']),
        });
        print('success2');
      }
    } catch (e) {
      print('Error updating year stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPrimaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color.fromARGB(255, 253, 216, 83),
        ),
        title: const Text(
          'Alumni Tracking System',
          style: TextStyle(color: Color.fromARGB(255, 253, 216, 83)),
        ),
        backgroundColor: const Color(0xFF0b0a5f),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
                MediaQuery.of(context).size.width > 600 ? 16.0 : 8.0),
            child: SizedBox(
              width: _getFormWidth(context),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width > 600 ? 16.0 : 12.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSkillsSelection(),
                        SizedBox(
                            height: MediaQuery.of(context).size.width > 600
                                ? 20
                                : 16),
                        _buildDropdownQuestion(
                          title:
                              'The skills you\'ve highlighted helped you in pursuing your career path.',
                          controllerKey: 'skill_impact',
                          options: _likertScaleOptions,
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.width > 600
                                ? 20
                                : 16),
                        _buildDropdownQuestion(
                          title:
                              'Time taken to land first job after graduation',
                          controllerKey: 'employment_duration',
                          options: _employmentDurationOptions,
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.width > 600
                                ? 20
                                : 16),
                        if (information['employment_status'] != 'Others') ...[
                          _buildDropdownQuestion(
                            title:
                                'Your first job aligns with your current job',
                            controllerKey: 'job_alignment',
                            options: _likertScaleOptions,
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.width > 600
                                  ? 20
                                  : 16),
                          _buildDropdownQuestion(
                            title:
                                'The program you took in OLOPSC matches your current job.',
                            controllerKey: 'program_match',
                            options: _likertScaleOptions,
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.width > 600
                                  ? 20
                                  : 16),
                          _buildDropdownQuestion(
                            title: 'You are satisfied with your current job.',
                            controllerKey: 'job_satisfaction',
                            options: _likertScaleOptions,
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.width > 600
                                  ? 20
                                  : 16),
                        ],
                        SizedBox(
                            height: MediaQuery.of(context).size.width > 600
                                ? 30
                                : 20),
                        ElevatedButton(
                          onPressed:
                              _selectedSkillsCount >= _kMinSkillSelections &&
                                      !_isSubmitting
                                  ? _submitForm
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(11, 10, 95, 1),
                            minimumSize: Size(
                              double.infinity,
                              MediaQuery.of(context).size.width > 600 ? 50 : 40,
                            ),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'SUBMIT',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 253, 216, 83),
                                    fontSize:
                                        MediaQuery.of(context).size.width > 600
                                            ? 16
                                            : 14,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}
