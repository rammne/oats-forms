import 'package:alumni/compontents/app_colors.dart';
import 'package:alumni/compontents/profile_info_tile.dart';
import 'package:alumni/compontents/question_card.dart';
import 'package:alumni/compontents/answer_card.dart';
import 'package:flutter/material.dart';
import 'package:alumni/services/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  final String docID;
  final FirestoreService _firestoreService = FirestoreService();

  ProfileScreen({Key? key, required this.docID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: StreamBuilder(
          stream: _firestoreService.alumni.doc(docID).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final doc = snapshot.data!;
            final alumniData = doc.data() as Map<String, dynamic>;
            final docId = doc.id;
            return Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                      const Color.fromARGB(100, 0, 0, 0), BlendMode.srcATop),
                  image: NetworkImage(
                      'https://lh3.googleusercontent.com/d/1ZFqS4S9ZdUdUAL1Vl2yLKeNkBMcpsLDU'),
                  opacity: 0.25,
                )),
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(context, alumniData),
                    _buildProfileContent(alumniData, docId),
                  ],
                ));
          },
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, dynamic alumniData) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: const Color.fromRGBO(11, 10, 95, 1),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Welcome ${alumniData['last_name']}, ${alumniData['first_name']}!',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  SliverList _buildProfileContent(dynamic alumniData, String docId) {
    return SliverList(
      delegate: SliverChildListDelegate([
        LayoutBuilder(
          builder: (context, constraints) {
            // If width is less than 600, use vertical layout
            if (constraints.maxWidth < 600) {
              return _buildVerticalLayout(alumniData, docId);
            }
            // Otherwise, use horizontal layout
            return _buildHorizontalLayout(alumniData, docId);
          },
        ),
      ]),
    );
  }

  Widget _buildHorizontalLayout(dynamic alumniData, String docId) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Aligns children at the top
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16), // Consistent margin
            decoration: BoxDecoration(
              color: const Color.fromARGB(121, 249, 249, 249),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ProfileSection(alumniData: alumniData, docId: docId),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16), // Consistent margin
            decoration: BoxDecoration(
              color: const Color.fromARGB(121, 249, 249, 249),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: AlumniFeedbackSection(alumniData),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(dynamic alumniData, String docId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(122, 255, 255, 255),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ProfileSection(alumniData: alumniData, docId: docId),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(122, 255, 255, 255),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: AlumniFeedbackSection(alumniData),
          ),
        ),
      ],
    );
  }
}

class ProfileSection extends StatelessWidget {
  final Map<String, dynamic> alumniData;
  final String docId;

  const ProfileSection({required this.alumniData, required this.docId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(11, 10, 95, 1),
          ),
        ),
        const SizedBox(height: 16),
        ProfileInfoTile(
          label: 'ID',
          value: alumniData['alumni_id'] ?? '',
          onChanged: (val) async {
            alumniData['alumni_id'] = val;
            await FirebaseFirestore.instance
                .collection('alumni')
                .doc(docId)
                .update({'alumni_id': val});
          },
        ),
        ProfileInfoTile(
          label: 'First Name',
          value: alumniData['first_name'] ?? '',
          onChanged: (val) async {
            alumniData['first_name'] = val;
            await FirebaseFirestore.instance
                .collection('alumni')
                .doc(docId)
                .update({'first_name': val});
          },
        ),
        ProfileInfoTile(
          label: 'Middle Name',
          value: alumniData['middle_name'] ?? '',
          onChanged: (val) async {
            alumniData['middle_name'] = val;
            await FirebaseFirestore.instance
                .collection('alumni')
                .doc(docId)
                .update({'middle_name': val});
          },
        ),
        ProfileInfoTile(
          label: 'Last Name',
          value: alumniData['last_name'] ?? '',
          onChanged: (val) async {
            alumniData['last_name'] = val;
            await FirebaseFirestore.instance
                .collection('alumni')
                .doc(docId)
                .update({'last_name': val});
          },
        ),
        ProfileInfoTile(
          label: 'Degree',
          value: alumniData['degree'],
          onChanged: (val) async {
            alumniData['degree'] = val;
            await FirebaseFirestore.instance
                .collection('alumni')
                .doc(docId)
                .update({'degree': val});
          },
        ),
        ProfileInfoTile(
          label: 'Email',
          value: alumniData['email'],
          onChanged: (val) async {
            alumniData['email'] = val;
            await FirebaseFirestore.instance
                .collection('alumni')
                .doc(docId)
                .update({'email': val});
          },
        ),
        ProfileInfoTile(
          label: 'Date of Birth',
          value: alumniData['date_of_birth'],
          onChanged: (val) async {
            alumniData['date_of_birth'] = val;
            await FirebaseFirestore.instance
                .collection('alumni')
                .doc(docId)
                .update({'date_of_birth': val});
          },
        ),
        ProfileInfoTile(
          label: 'Year Graduated',
          value: alumniData['year_graduated'],
          onChanged: (val) async {
            alumniData['year_graduated'] = val;
            await FirebaseFirestore.instance
                .collection('alumni')
                .doc(docId)
                .update({'year_graduated': val});
          },
        ),
        ProfileInfoTile(
          label: 'Employment Status',
          value: alumniData['employment_status'],
          onChanged: (val) async {
            alumniData['employment_status'] = val;
            await FirebaseFirestore.instance
                .collection('alumni')
                .doc(docId)
                .update({'employment_status': val});
          },
        ),
        ProfileInfoTile(
          label: 'Occupation',
          value: alumniData['occupation'],
          onChanged: (val) async {
            alumniData['occupation'] = val;
            await FirebaseFirestore.instance
                .collection('alumni')
                .doc(docId)
                .update({'occupation': val});
          },
        ),
      ],
    );
  }
}

class AlumniFeedbackSection extends StatelessWidget {
  final dynamic alumniData;

  AlumniFeedbackSection(this.alumniData);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alumni Feedback',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(11, 10, 95, 1),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Question 1",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        QuestionCard(
          question: 'What are the life skills OLOPSC has taught you?',
        ),
        Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${alumniData['first_name']} ${alumniData['last_name']}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5),
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          "${alumniData['question_1'].join(', ')}",
                          textAlign: TextAlign.right,
                        ),
                      ],
                    )),
              ],
            )),
        Text(
          "Question 2",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        QuestionCard(
          question:
              'How did these skills help you in pursuing your career path?',
        ),
        // Align(
        //   alignment: Alignment.centerRight,
        //   child: Text(
        //      "${alumniData['first_name']} ${alumniData['last_name']}",
        //       style: TextStyle(
        //         fontSize: 14,
        //         color: Colors.black,
        //         fontWeight: FontWeight.bold,
        //       ),
        //   ),
        // ),
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${alumniData['first_name']} ${alumniData['last_name']}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AnswerCard(
                answer: alumniData['question_2'],
              ),
            ],
          ),
        ),
        Text(
          "Question 3",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        QuestionCard(
          question: 'Does your first job align with your current job?',
        ),

        Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${alumniData['first_name']} ${alumniData['last_name']}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AnswerCard(
                answer: alumniData['question_3'],
              ),
            ],
          ),
        ),
        Text(
          "Question 4",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        QuestionCard(
          question:
              'How long did it take to land your first job after graduation?',
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${alumniData['first_name']} ${alumniData['last_name']}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AnswerCard(
                answer: alumniData['question_4'],
              ),
            ],
          ),
        ),
        Text(
          "Question 5",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        QuestionCard(
          question: 'Does your OLOPSC program match your current job?',
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${alumniData['first_name']} ${alumniData['last_name']}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AnswerCard(
                answer: alumniData['question_5'],
              ),
            ],
          ),
        ),
        Text(
          "Question 6",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        QuestionCard(
          question: 'Are you satisfied with your current job?',
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${alumniData['first_name']} ${alumniData['last_name']}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AnswerCard(
                answer: alumniData['question_6'],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
