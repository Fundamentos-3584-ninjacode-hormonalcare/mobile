import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/domain/services/auth_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/shared/presentation/pages/home_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/presentation/pages/select_user_type.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  final _authService = AuthService();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final token = await _authService.signIn(_emailController.text, _passwordController.text);
        if (token != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid credentials')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset(
            '../../../../../../web/icons/Icon-192.png',
            height: 40,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome to HormonalCare',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              AuthForm(
                isSignUp: false,
                onSubmit: _submit,
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
              ),
              SizedBox(height: 40),
              Text(
                "Don't have an account?",
                style: TextStyle(color: Colors.black87),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelectUserType()),
                  );
                },
                child: Text(
                  'Sign up',
                  style: TextStyle(
                    color: Colors.blueGrey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthForm extends StatelessWidget {
  final bool isSignUp;
  final VoidCallback onSubmit;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const AuthForm({
    Key? key,
    required this.isSignUp,
    required this.onSubmit,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          if (isSignUp)
            TextFormField(
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onSubmit,
            child: Text(isSignUp ? 'Sign Up' : 'Sign In'),
          ),
        ],
      ),
    );
  }
}