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
  static const _kPrimaryColor = Color(0xFFFFD231);

  // Form Controllers
  late Map<String, TextEditingController> _questionControllers;

  late Map<String, int> _question1Stats;
  late Map<String, int> _question2Stats;
  late Map<String, int> _question3Stats;
  late Map<String, int> _question5Stats;
  late Map<String, int> _question6Stats;

  // Alumni reference
  final FirestoreService alumni = FirestoreService();

  // Alumni Inputs
  late final Map information = widget.userInformation;

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

  void _initializeControllers() {
    _questionControllers = {
      'skill_impact': TextEditingController(),
      'job_alignment': TextEditingController(),
      'employment_duration': TextEditingController(),
      'program_match': TextEditingController(),
      'job_satisfaction': TextEditingController(),
    };
    _question1Stats = {
      'strongly_agree': 0,
      'agree': 0,
      'neutral': 0,
      'disagree': 0,
      'strongly_disagree': 0,
    };
    _question2Stats = {
      'strongly_agree': 0,
      'agree': 0,
      'neutral': 0,
      'disagree': 0,
      'strongly_disagree': 0,
    };
    _question3Stats = {
      'strongly_agree': 0,
      'agree': 0,
      'neutral': 0,
      'disagree': 0,
      'strongly_disagree': 0,
    };
    _question5Stats = {
      'strongly_agree': 0,
      'agree': 0,
      'neutral': 0,
      'disagree': 0,
      'strongly_disagree': 0,
    };
    _question6Stats = {
      'strongly_agree': 0,
      'agree': 0,
      'neutral': 0,
      'disagree': 0,
      'strongly_disagree': 0,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Life Skills ($_selectedSkillsCount/$_kMaxSkillSelections)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _skillsMap.keys.map((skill) {
            return FilterChip(
              label: Text(skill),
              selected: _skillsMap[skill]!,
              onSelected: (selected) => _toggleSkillSelection(skill, selected),
              selectedColor: _kPrimaryColor.withOpacity(0.3),
              checkmarkColor: Colors.blue,
            );
          }).toList(),
        ),
        if (_selectedSkillsCount < _kMinSkillSelections)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please select at least $_kMinSkillSelections skills',
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownQuestion({
    required String title,
    required String controllerKey,
    required List<String> options,
    bool Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 450,
          child: DropdownButtonFormField2<String>(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            hint: const Text('Select an option'),
            items: options
                .map((option) =>
                    DropdownMenuItem(value: option, child: Text(option)))
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
              height: 50,
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

      await _updateQuestion1Stats();

      // Set the new alumni document
      await _setAlumniDocument(document);

      // Update graduation year statistics
      await _updateYearStats();

      // Update question statistics
      await _updateQuestionStats('question_2', _question2Stats);

      await _updateQuestionStats('question_3', _question3Stats);

      await _updateQuestionStats('question_5', _question5Stats);

      await _updateQuestionStats('question_6', _question6Stats);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationPage(
            docID: documentID,
          ),
        ),
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

  // Function to update the stats of the alumni from question 1
  Future<void> _updateQuestion1Stats() async {
    try {
      final CollectionReference collectionRef =
          FirebaseFirestore.instance.collection('question_1');

      for (String skill in _alumniSkills) {
        final DocumentReference skillDoc = collectionRef.doc(skill);

        final DocumentSnapshot skillSnapshot = await skillDoc.get();

        if (skillSnapshot.exists) {
          await skillDoc.update({
            'count': (skillSnapshot.data() as Map<String, dynamic>)['count'] + 1
          });
        }
      }
    } catch (e) {
      print('Error updating question 1 stats: $e');
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
      print('success3');
    } catch (e) {
      print('Error updating $questionId stats: ${e}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kPrimaryColor,
      appBar: AppBar(
        title: const Text('Alumni Tracking System'),
        backgroundColor: _kPrimaryColor,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSkillsSelection(),
                      const SizedBox(height: 20),
                      _buildDropdownQuestion(
                        title:
                            'The skills you\'ve highlighted helped you in pursuing your career path.',
                        controllerKey: 'skill_impact',
                        options: _likertScaleOptions,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdownQuestion(
                        title: 'Time taken to land first job after graduation',
                        controllerKey: 'employment_duration',
                        options: _employmentDurationOptions,
                      ),
                      const SizedBox(height: 20),
                      if (widget.userInformation['employment_status'] !=
                          'Others') ...[
                        _buildDropdownQuestion(
                          title: 'Your first job aligns with your current job',
                          controllerKey: 'job_alignment',
                          options: _likertScaleOptions,
                        ),
                        const SizedBox(height: 20),
                        _buildDropdownQuestion(
                            title:
                                'The program you took in OLOPSC matches your current job.',
                            controllerKey: 'program_match',
                            options: _likertScaleOptions),
                        const SizedBox(height: 20),
                        _buildDropdownQuestion(
                            title: 'You are satisfied with your current job.',
                            controllerKey: 'job_satisfaction',
                            options: _likertScaleOptions),
                        const SizedBox(height: 20),
                      ],
                      const SizedBox(height: 30),
                      ElevatedButton(
                    onPressed: _selectedSkillsCount >= _kMinSkillSelections &&
                            !_isSubmitting
                        ? _submitForm
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[300],
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
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
    );
  }

  @override
  void dispose() {
    _questionControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}
