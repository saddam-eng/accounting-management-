import 'package:adminaccountingapp/views/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'consts/string.dart';
import 'controllers/databasehelper.dart';
import 'firebase_options.dart';
import 'widget/custom_textfield.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _initializeFirebaseMessaging();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      textDirection: TextDirection.rtl,
      theme: FlexThemeData.light(fontFamily: "k", scheme: FlexScheme.tealM3,),
      // The Mandy red, dark theme.
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.mandyRed),
      // Use dark or light theme based on system setting.

      themeMode: ThemeMode.system,
      home: const LoginPage(),
    );
  }
}
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var isChecked = false.obs;
  var isLoading = false.obs;

  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  final _keyForm = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth.authStateChanges().listen((User? user) async {
      if (user != null && mounted) {

        if (user != null) {

            Get.to(HomePage());

        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 400,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                      // colorFilter:  ColorFilter.srgbToLinearGamma(),
                        image: AssetImage('assets/images/background.png'),
                        fit: BoxFit.fill)),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 30,
                      width: 80,
                      height: 200,
                      child: FadeInUp(
                          duration: const Duration(seconds: 1),
                          child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image:
                                    AssetImage('assets/images/light-1.png'))),
                          )),
                    ),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      child: FadeInUp(
                          duration: const Duration(milliseconds: 1200),
                          child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image:
                                    AssetImage('assets/images/light-2.png'))),
                          )),
                    ),
                    Positioned(
                      right: 40,
                      top: 40,
                      width: 80,
                      height: 150,
                      child: FadeInUp(
                          duration: const Duration(milliseconds: 1300),
                          child: Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('assets/images/clock.png'))),
                          )),
                    ),
                    Positioned(
                      child: FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: Container(
                            margin: const EdgeInsets.only(top: 50),
                            child: const Center(
                              child: Text(
                                logIn,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    FadeInUp(
                        duration: const Duration(milliseconds: 1800),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color.fromRGBO(4, 86, 82, 1.0)),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color.fromRGBO(143, 148, 251, .2),
                                    blurRadius: 20.0,
                                    offset: Offset(0, 10))
                              ]),
                          child: Form(
                            key: _keyForm,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Color.fromRGBO(
                                                  4, 86, 82, 1.0)))),
                                  child: customTextFieldd(
                                      hint: "$email", controller: emailController),

                                ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: customTextFieldd(
                                      isPass: true,
                                      hint: password,
                                      controller: passwordController),

                                )
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(
                      height: 30,
                    ),
                    FadeInUp(
                        duration: const Duration(milliseconds: 1900),
                        child: InkWell(
                          onTap: () async {
                            if (_keyForm.currentState!.validate()) {
                              isLoading(true);
                              setState(() {});
                              try {
                                await _databaseHelper
                                    .loginMethod(
                                    context: context,
                                    emailController:
                                    emailController.text,
                                    passwordController:
                                    passwordController.text)
                                    .then((value) async {
                                  if (value != null) {
                                    Get.offAll(HomePage());
                                  } else {
                                    // Get.offAll(HomePage());
                                    isLoading(false);
                                    setState(() {});
                                  }
                                });
                              } on FirebaseAuthException catch (e) {
                                showDialog(
                                    context: context,
                                    builder: (s) {
                                      return Center(
                                        child: Text(e.message.toString()),
                                      );
                                    });
                              }
                            }
                          },

                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(colors: [
                                  Color.fromRGBO(4, 86, 82, 1.0),
                                  Color.fromRGBO(
                                      46, 128, 124, 1.0),
                                ])),
                            child: Center(
                              child: isLoading.value
                                  ? const CircularProgressIndicator(color: Colors.white,)
                                  : const Text(
                                    logIn,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                            ),
                          ),
                        )),
                    const SizedBox(
                      height: 70,
                    ),
                    FadeInUp(
                        duration: const Duration(milliseconds: 2000),
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Color.fromRGBO(4, 86, 82, 1.0)),
                        )),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}





late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


Future<void> _initializeFirebaseMessaging() async {
  // Initialize the local notification plugin
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Request permission to receive notifications



  // Set up background message handling
  FirebaseFirestore.instance.collection('users').snapshots().listen((event) {event.docChanges.forEach((element) {
    if(element.type==DocumentChangeType.modified){_showNotification(element.doc.get('name'),element.newIndex);}

  });});
}


Future<void> _showNotification(String title, key) async {
  int i=6;
  // Display the notification using the local notification plugin
   AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'com.d',
    'saddda,',
    channelDescription: 'Your Channel Description',

  groupKey: "key",

    icon: '@mipmap/ic_launcher',
  );
   NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    key,
    'تم الموافقه علي الفاتوره او السند للعميل ',
    title,
    platformChannelSpecifics,
  );
  i++;
}








