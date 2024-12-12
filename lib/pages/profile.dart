import 'package:alumni/compontents/app_colors.dart';
import 'package:alumni/compontents/profile_info_tile.dart';
import 'package:alumni/compontents/question_card.dart';
import 'package:alumni/compontents/answer_card.dart';
import 'package:flutter/material.dart';
import 'package:alumni/services/firebase.dart';

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

            final alumniData = snapshot.data!;
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/d/1A9nZdV4Y4kXErJlBOkahkpODE7EVhp1x'
                  ),
                  alignment: Alignment.bottomRight,
                  scale: 2.5,
                )
              ),
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(context, alumniData),
                  _buildProfileContent(alumniData),
                ],
              ),
            );
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
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Welcome ${alumniData['last_name']}, ${alumniData['first_name']}!',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  SliverList _buildProfileContent(dynamic alumniData) {
    return SliverList(
      delegate: SliverChildListDelegate([
        LayoutBuilder(
          builder: (context, constraints) {
            // If width is less than 600, use vertical layout
            if (constraints.maxWidth < 600) {
              return _buildVerticalLayout(alumniData);
            }
            // Otherwise, use horizontal layout
            return _buildHorizontalLayout(alumniData);
          },
        ),
      ]),
    );
  }

  
  Widget _buildHorizontalLayout(dynamic alumniData) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start, // Aligns children at the top
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
            child: ProfileSection(alumniData),
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

  Widget _buildVerticalLayout(dynamic alumniData) {
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
            child: ProfileSection(alumniData),
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
                offset: Offset(0,4),
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
  final dynamic alumniData;

  ProfileSection(this.alumniData);

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
          label: 'Full Name',
          value: '${alumniData['first_name']} ${alumniData['middle_name']} ${alumniData['last_name']}',
        ),
        ProfileInfoTile(
          label: 'Degree',
          value: alumniData['degree'],
        ),
        ProfileInfoTile(
          label: 'Email',
          value: alumniData['email'],
        ),
        ProfileInfoTile(
          label: 'Date of Birth',
          value: alumniData['date_of_birth'],
        ),
        ProfileInfoTile(
          label: 'Year Graduated',
          value: alumniData['year_graduated'],
        ),
        ProfileInfoTile(
          label: 'Employment Status',
          value: alumniData['employment_status'],
        ),
        ProfileInfoTile(
          label: 'Occupation',
          value: alumniData['occupation'],
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
        QuestionCard(
          question: 'What are the life skills OLOPSC has taught you?',
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AnswerCard(
            answer: alumniData['question_1'],
          ),
        ),
        QuestionCard(
          question: 'How did these skills help you in pursuing your career path?',
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AnswerCard(
            answer: alumniData['question_2'],
          ),
        ),
        QuestionCard(
          question: 'Does your first job align with your current job?',
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AnswerCard(
            answer: alumniData['question_3'],
          ),
        ),
        QuestionCard(
          question: 'How long did it take to land your first job after graduation?',
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AnswerCard(
            answer: alumniData['question_4'],
          ),
        ),
        QuestionCard(
          question: 'Does your OLOPSC program match your current job?',
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AnswerCard(
            answer: alumniData['question_5'],
          ),
        ),
        QuestionCard(
          question: 'Are you satisfied with your current job?',
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AnswerCard(
            answer: alumniData['question_6'],
          ),
        ),
      ],
    );
  }
}
