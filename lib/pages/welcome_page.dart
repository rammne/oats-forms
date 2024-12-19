import 'package:alumni/pages/home_page.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late final GlobalKey<FormState> formKey;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
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
                    });
                  },
                ),
                const Text(
                  'I am an OLOPSC Alumni',
                  style: TextStyle(fontSize: 18),
                )
              ],
            ),
            if (isChecked == true) _buildGetStartedButton(context),
          ],
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
        child: const Text(
          'Get Started',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
