import 'package:flutter/material.dart';

class MedicalRecordScreen extends StatefulWidget {
  @override
  _MedicalRecordScreenState createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // 5 pestañas en el TabBar
    _tabController.addListener(_handleTabSelection); // Añadimos un listener para manejar el cambio de pestañas
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection); // Eliminamos el listener cuando ya no se necesite
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Función para manejar el desplazamiento del TabBar cuando se cambia de pestaña
  void _handleTabSelection() {
    // Verifica si el índice actual es el último o el primero para evitar errores de desplazamiento
    if (_tabController.indexIsChanging) {
      // Posición de la pestaña actual
      double tabPosition = _tabController.index.toDouble();

      // Ajusta la posición del scroll para desplazar el TabBar un poco más al seleccionar un nuevo tab
      _scrollController.animateTo(
        tabPosition * 120, // Ajustamos el valor para que el tab no quede en la esquina
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Función para mostrar el menú flotante
  void _showPatientInfo() {
    showDialog(
      context: context,
      barrierDismissible: true, // Hace que se cierre al hacer clic fuera del diálogo
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView( // Solución para evitar el desbordamiento
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Encabezado con el avatar del paciente
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    child: Icon(Icons.person, color: Colors.white), // Asegúrate de reemplazar con la ruta correcta de tu imagen
                  ),
                  SizedBox(height: 15),
                  // Campos de información del paciente
                  _buildInfoField('First name', 'Ana María'),
                  SizedBox(height: 10),
                  _buildInfoField('Last name', 'López'),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildInfoField('Gender', 'Female')),
                      SizedBox(width: 10),
                      Expanded(child: _buildInfoField('Birthday', '07/09/1990')),
                    ],
                  ),
                  SizedBox(height: 10),
                  _buildInfoField('Phone number', '+51 987 123 567'),
                  SizedBox(height: 10),
                  _buildInfoField('Email', 'anamarialopez@gmail.com'),
                  SizedBox(height: 10),
                  _buildInfoField('Type of blood', 'O+'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar el diálogo
                    },
                    child: Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Función para construir los campos de información
  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: Text('Medical record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con nombre y edad, que abre el menú flotante al hacer clic
            GestureDetector(
              onTap: _showPatientInfo, // Llama a la función que abre el menú flotante
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF4B5A62), // Color de fondo del encabezado
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blueGrey[200],
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ana María López',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      'Age: 32',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Menú de pestañas (TabBar)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController, // Añadimos el ScrollController
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.black,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: 'Patient History'),
                  Tab(text: 'Diagnosis & Treatments'),
                  Tab(text: 'Medical Tests'), // Pestaña renombrada
                  Tab(text: 'External Reports'), // Nueva pestaña
                  Tab(text: 'Consultation History'), // Nueva pestaña de Consultations
                ],
              ),
            ),
            SizedBox(height: 20),

            // Contenido de las pestañas (TabBarView)
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Contenido de la pestaña 1
                  ListView(
                    children: [
                      Text(
                        'Personal history:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Chronic conditions: Hypothyroidism diagnosed at age 28, currently on Levothyroxine 100 mcg daily.\n'
                        'Surgeries: Appendectomy at age 16.\n'
                        'Allergies: Allergic to penicillin.\n'
                        'Medications: Levothyroxine.\n'
                        'Lifestyle: Non-smoker, occasional alcohol consumption (social drinking).\n'
                        'Previous illnesses: Recurrent urinary tract infections in the past, no recent episodes.',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Family history:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Mother: Diagnosed with type 2 diabetes at age 45, history of hypertension.\n'
                        'Father: History of hypercholesterolemia, passed away at age 60 from a heart attack.\n'
                        'Siblings: One brother, healthy, no chronic conditions.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  
                  // Contenido de la pestaña 2 (Diagnosis & Treatments)
ListView(
  padding: EdgeInsets.all(16),
  children: [
    // Caja con fondo y bordes redondeados
    Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Diagnosis Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Diagnosis',
                style: TextStyle(
                  fontSize: 16,  // Reducción de tamaño de fuente
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '06/09/24',  // Fecha en el formato de la imagen
                style: TextStyle(
                    fontSize: 12,  // Reducción de tamaño de fuente
                    fontWeight: FontWeight.bold,
                  ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Presumptive diagnosis: Hypothyroidism, with suspicion of inadequate medication dose or suboptimal absorption of Levothyroxine.',
            style: TextStyle(fontSize: 14),  // Reducción de tamaño de fuente
          ),
          SizedBox(height: 20),

          // Medication Section with Headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Medication',
                  style: TextStyle(
                    fontSize: 12,  // Reducción de tamaño de fuente
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Concentration',
                  style: TextStyle(
                    fontSize: 10,  // Reducción de tamaño de fuente
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Unit',
                  style: TextStyle(
                    fontSize: 10,  // Reducción de tamaño de fuente
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Frecuency',
                  style: TextStyle(
                    fontSize: 10,  // Reducción de tamaño de fuente
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Levothyroxine',
                  style: TextStyle(fontSize: 14),  // Reducción de tamaño de fuente
                ),
              ),
              Expanded(
                child: Text(
                  '100',
                  style: TextStyle(fontSize: 14),  // Reducción de tamaño de fuente
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'mcg',
                  style: TextStyle(fontSize: 14),  // Reducción de tamaño de fuente
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  '8 hrs',
                  style: TextStyle(fontSize: 14),  // Reducción de tamaño de fuente
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Treatment Section
          Text(
            'Treatment',
            style: TextStyle(
              fontSize: 16,  // Reducción de tamaño de fuente
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Depending on lab results, consider increasing the dose or switching to a different form of thyroid hormone replacement.',
            style: TextStyle(fontSize: 14),  // Reducción de tamaño de fuente
          ),
        ],
      ),
    ),
  ],
),


                  // Contenido de la pestaña 3 (Medical Tests)
                  ListView(
  padding: EdgeInsets.all(16),
  children: [
    // Sección de Glucose and Diabetes Monitoring
    Text(
      'Glucose and Diabetes Monitoring',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(height: 10),

    // Fasting Glucose Test
    Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Fasting Glucose Test',
            style: TextStyle(fontSize: 16),
          ),
          Row(
            children: [
              Text(
                '18/04/24',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(width: 10),
              // Botón de descarga con borde oscuro, relleno oscuro y ícono blanco
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[700], // Relleno oscuro
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.download, size: 24, color: Colors.white),  // Icono blanco
              ),
            ],
          ),
        ],
      ),
    ),

    // OGTT Test
    Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'OGTT',
            style: TextStyle(fontSize: 16),
          ),
          Row(
            children: [
              Text(
                '18/04/24',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(width: 10),
              // Botón de descarga con borde oscuro, relleno oscuro y ícono blanco
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[700], // Relleno oscuro
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.download, size: 24, color: Colors.white),  // Icono blanco
              ),
            ],
          ),
        ],
      ),
    ),

    // Sección de Hormone Levels
    Text(
      'Hormone Levels',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(height: 10),

    // Cortisol Test
    Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Cortisol test',
            style: TextStyle(fontSize: 16),
          ),
          Row(
            children: [
              Text(
                '22/04/24',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(width: 10),
              // Botón de descarga con borde oscuro, relleno oscuro y ícono blanco
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[700], // Relleno oscuro
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.download, size: 24, color: Colors.white),  // Icono blanco
              ),
            ],
          ),
        ],
      ),
    ),

    // ACTH Test
    Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ACTH test',
            style: TextStyle(fontSize: 16),
          ),
          Row(
            children: [
              Text(
                '18/04/24',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(width: 10),
              // Botón de descarga con borde oscuro, relleno oscuro y ícono blanco
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[700], // Relleno oscuro
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.download, size: 24, color: Colors.white),  // Icono blanco
              ),
            ],
          ),
        ],
      ),
    ),
  ],
)
,

                  // Contenido de la pestaña 4 (External Reports)
                  ListView(
  padding: EdgeInsets.all(16),
  children: [
    // Primer Item
    Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '18/04/24',
            style: TextStyle(fontSize: 16),
          ),
          // Botón de descarga
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[700], // Relleno oscuro
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.download, size: 24, color: Colors.white),  // Ícono blanco
          ),
        ],
      ),
    ),

    // Segundo Item
    Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '18/04/24',
            style: TextStyle(fontSize: 16),
          ),
          // Botón de descarga
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[700], // Relleno oscuro
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.download, size: 24, color: Colors.white),  // Ícono blanco
          ),
        ],
      ),
    ),

    // Tercer Item
    Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '22/04/24',
            style: TextStyle(fontSize: 16),
          ),
          // Botón de descarga
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[700], // Relleno oscuro
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.download, size: 24, color: Colors.white),  // Ícono blanco
          ),
        ],
      ),
    ),

    // Cuarto Item
    Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '18/04/24',
            style: TextStyle(fontSize: 16),
          ),
          // Botón de descarga
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[700], // Relleno oscuro
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.download, size: 24, color: Colors.white),  // Ícono blanco
          ),
        ],
      ),
    ),
  ],
)
,

                  // Contenido de la pestaña 5 (Consultation History)
                  Center(child: Text('Consultation History content')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
