import 'package:alumni/pages/home_page.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late final GlobalKey<FormState> formKey;
  bool isChecked = false;
  final TextEditingController idController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    idController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFffea56),
      appBar: _buildAppBar(),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Color.fromARGB(100, 0, 0, 0), BlendMode.srcATop),
            image: NetworkImage(
              'https://lh3.googleusercontent.com/d/1ZFqS4S9ZdUdUAL1Vl2yLKeNkBMcpsLDU',
            ),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderSection(),
              _buildAnimatedMessage(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value!;
                        errorMessage = null;
                      });
                    },
                  ),
                  const Text(
                    'I am an OLOPSC Alumni',
                    style: TextStyle(fontSize: 18),
                  )
                ],
              ),
              if (isChecked) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: Column(
                    children: [
                      TextField(
                        controller: idController,
                        decoration: const InputDecoration(
                          labelText: 'StudentID/AlumniID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: middleNameController,
                        decoration: const InputDecoration(
                          labelText: 'Middle Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B0A5F),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    isLoading = true;
                                    errorMessage = null;
                                  });
                                  final id = idController.text.trim();
                                  final first = firstNameController.text.trim();
                                  final middle =
                                      middleNameController.text.trim();
                                  final last = lastNameController.text.trim();
                                  if (id.isEmpty ||
                                      first.isEmpty ||
                                      middle.isEmpty ||
                                      last.isEmpty) {
                                    setState(() {
                                      errorMessage =
                                          'Please fill in all fields.';
                                      isLoading = false;
                                    });
                                    return;
                                  }
                                  try {
                                    // Check if alumni already exists in 'alumni' collection by alumni_id only
                                    final alumniQuery = await FirebaseFirestore
                                        .instance
                                        .collection('alumni')
                                        .where('alumni_id', isEqualTo: id)
                                        .limit(1)
                                        .get();
                                    if (alumniQuery.docs.isNotEmpty) {
                                      // Alumni exists, go to profile page
                                      Navigator.pushReplacementNamed(
                                        context,
                                        'profile',
                                        arguments: alumniQuery.docs.first.id,
                                      );
                                    } else {
                                      // Not found, go to basic-info-form
                                      Navigator.pushNamed(
                                        context,
                                        'basic-info-form',
                                        arguments: {
                                          'alumni_id': id,
                                          'first_name': first,
                                          'middle_name': middle,
                                          'last_name': last,
                                        },
                                      );
                                    }
                                  } catch (e) {
                                    setState(() {
                                      errorMessage =
                                          'Error connecting to server.';
                                    });
                                  } finally {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Proceed',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(11, 10, 95, 1),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OLOPSC Alumni Form',
                style: TextStyle(fontSize: 18, color: Color(0xFFffea56)),
              ),
              SizedBox(height: 4),
              Text(
                'OLOPSC Alumni Tracking System (OATS)',
                style: TextStyle(fontSize: 14, color: Color(0xFFffea56)),
              ),
            ],
          ),
          Image.network(
            'https://lh3.googleusercontent.com/d/1CcRXI71dz-jmNoZF_JZ2T0cq9NuyNq6t',
            scale: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Image.network(
            'https://lh3.googleusercontent.com/d/1tEYHz19SLQ5SzTyX_nd6oGZHikQqRpcX',
            cacheWidth: 740,
            cacheHeight: 263,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Made By: '),
              Opacity(
                opacity: 0.9,
                child: Image.network(
                  'https://lh3.googleusercontent.com/d/1VDWlFOEyS-rftjzmy1DtWYNf5HvDSDq3',
                  scale: 39.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            'Welcome, Alumni!',
            textAlign: TextAlign.center,
            textStyle:
                const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          TyperAnimatedText(
            'By answering this Alumni Form, you agree to share your information with the OLOPSC Alumni Tracking System.'
            '\nThe data will be used to evaluate the effectiveness of OLOPSC programs since 2002.'
            '\nAll information will be treated with strict confidentiality.'
            '\nTo proceed, click the button below.',
            textAlign: TextAlign.center,
            textStyle: const TextStyle(fontSize: 16),
            speed: const Duration(milliseconds: 30),
          ),
        ],
        pause: const Duration(milliseconds: 2000),
        isRepeatingAnimation: false,
        displayFullTextOnTap: true,
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B0A5F),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        onPressed: () {
          Navigator.pushNamed(context, 'basic-info-form');
        },
        child: const Text(
          'Get Started',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
