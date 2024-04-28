import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../appManager/dialog_manager.dart';
import '../appManager/error_manager.dart';
import '../appManager/firebase_manager.dart';
import '../appManager/view_manager.dart';
import '../model/login_model.dart';
import '../model/user_model.dart';
import '../widget/loading_btn.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _controllerEmailTextField = TextEditingController();
  TextEditingController _controllerPhoneNoTextField = TextEditingController();
  FocusNode emailFocusNode = FocusNode();
  FocusNode phoneNoFocusNode = FocusNode();
  TextEditingController _controllerPasswordTextField = TextEditingController();
  FocusNode passwordFocusNode = FocusNode();
  TextEditingController _controllerUsernameTextField = TextEditingController();
  FocusNode usernameFocusNode = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isRounded = false;
  String userEmail = "";
  bool isLoadingBtn = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controllerPhoneNoTextField.dispose();
    _controllerPasswordTextField.dispose();
    _controllerEmailTextField.dispose();
    _controllerUsernameTextField.dispose();
    super.dispose();
  }

  ///ฟังก์ชั่นการลงทะเบียนด้วยอีเมลและรหัสผ่าน
  void _register() async {
    setState(() {
      isLoadingBtn = true;
    });
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _controllerEmailTextField.text.trim(),
        password: _controllerPasswordTextField.text.trim(),
      );
      await FirebaseFirestore.instanceFor(app: Firebase.app())
          .collection('Users')
          .doc(userCredential.user!.uid)
          .set({
        'username': _controllerUsernameTextField.text,
        'password': _controllerPasswordTextField.text,
        'email': _controllerEmailTextField.text,
        'phoneNo': _controllerPhoneNoTextField.text,
        'profile': ""
      });
      setState(() {
        isLoadingBtn = false;
      });
      showDialogSuccess();
    } on FirebaseAuthException catch (e) {
      print('Failed to create user: ${e.message}');
      isLoadingBtn = false;
      _showAlertDialogError("เกิดข้อผิดพลาด", e.toString());
      // Handle errors such as weak password, email already in use, etc.
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        left: false,
        right: false,
        top: true,
        child: Container(
          margin: EdgeInsets.only(left: 16, right: 16, top: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 32),
                child: Text(
                  'สร้างบัญชีใหม่',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 36),
                ),
              ),
              Form(
                  key: formKey,
                  child: Column(
                    children: [
                      _usernameTextField(),
                      _emailTextField(),
                      _phoneNoTextField(),
                      _passwordTextField()
                    ],
                  )),
              _btnSignUp()
            ],
          ),
        ),
      ),
    );
  }

  ///ช่องกรอกอีเมล
  Widget _emailTextField() {
    return Container(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              "อีเมล",
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: FontSizeManager().textLSize,
                  color: ColorManager().textColor),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: Key('email'),
                  controller: _controllerEmailTextField,
                  focusNode: emailFocusNode,
                  validator: doubleFieldValidator.validateEmail,
                  style: TextStyle(
                    fontSize: FontSizeManager().textLSize,
                  ),
                  cursorColor: ColorManager().primaryColor,
                  textAlign: TextAlign.start,
                  // validator: doubleFieldValidator.validate,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.email,
                      color: ColorManager().primaryColor,
                    ),
                    fillColor: ColorManager().primaryColor.withOpacity(0.05),
                    filled: true,
                    hintText: "ระบุชื่ออีเมล",
                    contentPadding: EdgeInsets.all(8),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                          color: ColorManager().primaryColor, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                          color: ColorManager().lineSeparate, width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///ช่องกรอกรหัสผ่าน
  Widget _passwordTextField() {
    return Container(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              "รหัสผ่าน",
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: FontSizeManager().textLSize,
                  color: ColorManager().textColor),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: Key('password'),
                  controller: _controllerPasswordTextField,
                  focusNode: passwordFocusNode,
                  validator: doubleFieldValidator.validate,
                  obscureText: !isRounded,
                  style: TextStyle(
                    fontSize: FontSizeManager().textLSize,
                  ),
                  cursorColor: ColorManager().primaryColor,
                  textAlign: TextAlign.start,
                  // validator: doubleFieldValidator.validate,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock,
                      color: ColorManager().primaryColor,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isRounded
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 27,
                      ),
                      color: ColorManager().primaryColor,
                      onPressed: () {
                        setState(() {
                          isRounded = !isRounded;
                        });
                      },
                    ),
                    fillColor: ColorManager().primaryColor.withOpacity(0.05),
                    filled: true,
                    hintText: "ระบุรหัสผ่าน",
                    contentPadding: EdgeInsets.all(16),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                          color: ColorManager().primaryColor, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                          color: ColorManager().lineSeparate, width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///ช่องกรอกชื่อ
  Widget _usernameTextField() {
    return Container(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              "ชื่อผู้ใช้",
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: FontSizeManager().textLSize,
                  color: ColorManager().textColor),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: Key('username'),
                  controller: _controllerUsernameTextField,
                  focusNode: usernameFocusNode,
                  validator: doubleFieldValidator.validate,
                  style: TextStyle(
                    fontSize: FontSizeManager().textLSize,
                  ),
                  cursorColor: ColorManager().primaryColor,
                  textAlign: TextAlign.start,
                  // validator: doubleFieldValidator.validate,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person,
                      color: ColorManager().primaryColor,
                    ),
                    fillColor: ColorManager().primaryColor.withOpacity(0.05),
                    filled: true,
                    hintText: "ระบุชื่อผู้ใช้",
                    contentPadding: EdgeInsets.all(8),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                          color: ColorManager().primaryColor, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                          color: ColorManager().lineSeparate, width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///ช่องกรอกเบอร์โทรศัพท์
  Widget _phoneNoTextField() {
    return Container(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              "เบอร์โทรศัพท์",
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: FontSizeManager().textLSize,
                  color: ColorManager().textColor),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: Key('phoneNo'),
                  controller: _controllerPhoneNoTextField,
                  focusNode: phoneNoFocusNode,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  validator: doubleFieldValidator.validatePhone,
                  style: TextStyle(
                    fontSize: FontSizeManager().textLSize,
                  ),
                  cursorColor: ColorManager().primaryColor,
                  textAlign: TextAlign.start,
                  // validator: doubleFieldValidator.validate,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.phone,
                      color: ColorManager().primaryColor,
                    ),
                    fillColor: ColorManager().primaryColor.withOpacity(0.05),
                    filled: true,
                    hintText: "ระบุเบอร์โทรศัพท์",
                    contentPadding: EdgeInsets.all(8),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.red, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                          color: ColorManager().primaryColor, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                          color: ColorManager().lineSeparate, width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///ปุ่มการลงทะเบียน
  Widget _btnSignUp() {
    return isLoadingBtn
        ? ButtonLoading()
        : Container(
            margin: EdgeInsets.only(top: 32),
            child: Material(
              child: InkWell(
                onTap: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    usernameFocusNode.unfocus();
                    passwordFocusNode.unfocus();
                    emailFocusNode.unfocus();
                    phoneNoFocusNode.unfocus();
                    _register();
                  }
                },
                child: Ink(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFF31c5a3), Color(0xFFc0edcc)]),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    child: Center(
                      child: Text(
                        "ลงทะเบียน",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: FontSizeManager().defaultSize,
                            color: ColorManager().secondaryColor),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  ///แจ้งเตือนเมื่อลงทะเบียนสำเร็จ
  showDialogSuccess() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return DialogSuccess(
            title: 'ลงทะเบียนสำเร็จ',
            icon: Icon(
              Icons.check,
              size: 50,
              color: ColorManager().primaryColor,
            ),
            content: '',
            styleConfirm: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                elevation: 0,
                backgroundColor: ColorManager().primaryColor,
                padding: EdgeInsets.all(16)),
            textConfirmBtn: 'เสร็จสิ้น',
            textStyleConfirm: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: FontSizeManager().defaultSize,
                color: Colors.white),
            sizeContent: 0,
            onPress: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          );
        });
  }

  _showAlertDialogError(String title, String content) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
      ),
    );
  }
}

///ตรวจสอบว่ากรอกข้อมูลครบและถูกต้องหรือไม่
class doubleFieldValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return "กรุณากรอกข้อมูล";
    } else {
      return null;
    }
  }

  ///ตรวจสอบรูปแบบอีเมล
  static String? validateEmail(String? value) {
    final bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value ?? "");
    if (value == null || value.isEmpty) {
      return "กรุณากรอกข้อมูล";
    } else if (!emailValid) {
      return "รูปแบบอีเมลไม่ถูกต้อง";
    } else {
      return null;
    }
  }

  ///ตรวจสอบความยาวของเบอร์โทร
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "กรุณากรอกข้อมูล";
    } else if (value.length < 10) {
      return "กรุณากรอกตัวเลขให้ครบจำนวน";
    } else {
      return null;
    }
  }
}
