import 'package:flutter/material.dart';

class SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(10.0), // Aplicar bordes redondeados
          child: Image.asset(
            '../../../../../../web/icons/Icon-192.png', // Reemplaza con la ruta correcta de tu imagen
            height: 40, // Ajusta el tamaño según tu necesidad
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
              AuthForm(isSignUp: false), // Formulario compartido para inicio de sesión
              SizedBox(height: 40),
              Text(
                "Don't have an account?",
                style: TextStyle(color: Colors.black87),
              ),
              SizedBox(height: 10), // Añadir un espacio entre el texto y el botón
              TextButton(
                onPressed: () {
                  // Navegar a la pantalla de registro
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUp()),
                  );
                },
                child: Text(
                  'Sign up',
                  style: TextStyle(
                    color: Colors.blueGrey[700],
                    fontWeight: FontWeight.bold,
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

// Formulario reutilizable para Sign In y Sign Up
class AuthForm extends StatefulWidget {
  final bool isSignUp; // Definir si es Sign Up o Sign In
  const AuthForm({required this.isSignUp});

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Manejar la lógica de inicio de sesión o registro
      if (widget.isSignUp) {
        print('Sign Up with Email: ${_emailController.text}');
      } else {
        print('Sign In with Email: ${_emailController.text}');
      }
      print('Password: ${_passwordController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[100], // Fondo de la tarjeta de inicio de sesión
        borderRadius: BorderRadius.circular(20),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Para evitar que el formulario crezca demasiado verticalmente
          children: <Widget>[
            Text(
              widget.isSignUp ? 'Sign Up' : 'Sign In',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            MouseRegion(
              cursor: SystemMouseCursors.click, // Cursor de "manito"
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 80,
                    vertical: 15,
                  ),
                  backgroundColor: Colors.blueGrey[700],
                ),
                child: Text(
                  widget.isSignUp ? 'Register' : 'Enter',
                  style: TextStyle(
                    color: Colors.white, // Cambiar el color del texto a blanco
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Pantalla de registro
class SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Color(0xFF6A828D), // Asegurando que el color del AppBar sea el mismo
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1), // Espacio para centrar el formulario
                AuthForm(isSignUp: true), // Formulario compartido para registro
                SizedBox(height: MediaQuery.of(context).size.height * 0.1), // Espacio debajo del formulario
              ],
            ),
          ),
        ),
      ),
    );
  }
}
