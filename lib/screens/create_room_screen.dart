import 'package:flutter/material.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() =>
      _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  static const Color bg = Color(0xFF090711);
  static const Color panel = Color(0xFF191529);
  static const Color gold = Color(0xFFFFD36A);
  static const Color purple = Color(0xFF8957F5);

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool isPrivate = false;
  bool hasPassword = false;
  bool allowRequests = true;
  bool isCreating = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void createRoom() {
    if (nameController.text.trim().isEmpty) {
      showMessage('من فضلك اكتب اسم الغرفة');
      return;
    }

    if (hasPassword &&
        passwordController.text.trim().length < 4) {
      showMessage('كلمة المرور لازم تكون 4 أحرف على الأقل');
      return;
    }

    final newRoom = <String, dynamic>{
      'name': nameController.text.trim(),
      'owner': 'KOKI USER',
      'description': descriptionController.text.trim(),
      'members': 1,
      'speakers': 1,
      'icon': Icons.workspace_premium,
      'isPrivate': isPrivate,
      'hasPassword': hasPassword,
      'password': hasPassword
          ? passwordController.text.trim()
          : '',
      'allowRequests': allowRequests,
    };

    Navigator.pop(context, newRoom);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: panel,
          foregroundColor: gold,
          centerTitle: true,
          title: const Text(
            'إنشاء غرفة جديدة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF352052),
                        Color(0xFF171126),
                      ],
                    ),
                    border: Border.all(
                      color: gold.withOpacity(0.4),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: gold,
                        size: 55,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'اصنع مملكتك الخاصة',
                        style: TextStyle(
                          color: gold,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'أنشئ غرفتك واجمع أصدقاءك في KOKI PARTY',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'اسم الغرفة',
                  style: TextStyle(
                    color: gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),

                TextField(
                  controller: nameController,
                  maxLength: 30,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDecoration(
                    'مثال: غرفة الملوك',
                    Icons.meeting_room,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'وصف الغرفة',
                  style: TextStyle(
                    color: gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),

                TextField(
                  controller: descriptionController,
                  maxLength: 150,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDecoration(
                    'اكتب وصفاً بسيطاً للغرفة',
                    Icons.description,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'إعدادات الغرفة',
                  style: TextStyle(
                    color: gold,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SwitchListTile(
                    value: isPrivate,
                    activeColor: gold,
                    title: const Text(
                      'غرفة خاصة',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'تحديد الغرفة كغرفة خاصة',
                      style: TextStyle(color: Colors.white54),
                    ),
                    secondary: const Icon(
                      Icons.lock,
                      color: gold,
                    ),
                    onChanged: (value) {
                      setState(() {
                        isPrivate = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SwitchListTile(
                    value: hasPassword,
                    activeColor: gold,
                    title: const Text(
                      'حماية بكلمة مرور',
                      style: TextStyle(color: Colors.white),
                    ),
                    secondary: const Icon(
                      Icons.password,
                      color: gold,
                    ),
                    onChanged: (value) {
                      setState(() {
                        hasPassword = value;
                      });
                    },
                  ),
                ),

                if (hasPassword) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration(
                      'كلمة مرور الغرفة',
                      Icons.lock_outline,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SwitchListTile(
                    value: allowRequests,
                    activeColor: gold,
                    title: const Text(
                      'السماح بطلب المايك',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'يمكن للأعضاء طلب الصعود للمقاعد',
                      style: TextStyle(color: Colors.white54),
                    ),
                    secondary: const Icon(
                      Icons.mic,
                      color: gold,
                    ),
                    onChanged: (value) {
                      setState(() {
                        allowRequests = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 25),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: purple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: purple.withOpacity(0.5),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: gold,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'الغرفة مجهزة بثمانية مقاعد صوتية.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isCreating ? null : createRoom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: bg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'إنشاء الغرفة 👑',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: gold),
      filled: true,
      fillColor: panel,
      counterStyle: const TextStyle(color: Colors.white38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
