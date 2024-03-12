import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ImagePicker picker = ImagePicker();
  XFile? pickedImage;
  List<String> textList = [];
  List<Widget> chipList = [];
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              Card(
                child: pickedImage == null
                    ? const SizedBox(
                        height: 150,
                        width: 100,
                        child: Center(child: Text('No Image')),
                      )
                    : Image.file(File(pickedImage!.path)),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () async {
                      try {
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          chipList.clear();
                          textList.clear();
                          pickedImage = image;
                          setState(() {});
                        }
                      } catch (e) {
                        log('error: $e');
                      }
                    },
                    child: const Text(
                      'Pick Image',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () async {
                      try {
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          chipList.clear();
                          textList.clear();
                          pickedImage = image;
                          setState(() {});
                        }
                      } catch (e) {
                        log('error: $e');
                      }
                    },
                    child: const Text(
                      'Take Picture',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () async {
                  // action
                  try {
                    chipList.clear();
                    textList.clear();
                    final textRecognizer =
                        TextRecognizer(script: TextRecognitionScript.latin);
                    final inputImage =
                        InputImage.fromFilePath(pickedImage!.path);
                    final RecognizedText recognizedText =
                        await textRecognizer.processImage(inputImage);
                    textList = recognizedText.text.split('\n');
                    for (var i = 0; i < textList.length; i++) {
                      chipList.add(
                        CustomChips(
                          teks: textList[i],
                          ontap: (p0) {
                            setState(() {
                              controller.text += ' $p0';
                            });
                          },
                        ),
                      );
                    }
                    setState(() {});
                    log('chiplist length: ${chipList.length}');
                  } catch (e) {
                    log('error proceed image: $e');
                  }
                },
                child: const Text(
                  'Proceed Image',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      chipList.clear();
                      for (var i = 0; i < textList.length; i++) {
                        if (!textList[i].contains(RegExp(r'[a-zA-Z]'))) {
                          chipList.add(CustomChips(
                            teks: textList[i],
                            ontap: (p0) {
                              setState(() {
                                controller.text += ' $p0';
                              });
                            },
                          ));
                        }
                      }
                      log(chipList.length.toString());
                      setState(() {});
                    },
                    child: const Text(
                      'Numbers',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      chipList.clear();
                      for (var i = 0; i < textList.length; i++) {
                        if (textList[i].contains(RegExp(r'[a-zA-Z]'))) {
                          chipList.add(
                            CustomChips(
                              teks: textList[i],
                              ontap: (p0) {
                                setState(() {
                                  controller.text += ' $p0';
                                });
                              },
                            ),
                          );
                        }
                      }
                      log(chipList.length.toString());
                      setState(() {});
                    },
                    child: const Text(
                      'Alphabet',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: controller,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        controller.text = '';
                      });
                    },
                    child: const Icon(Icons.clear),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(children: chipList),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomChips extends StatelessWidget {
  final String? teks;
  final Function(String)? ontap;
  const CustomChips({super.key, @required this.teks, @required this.ontap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ChoiceChip(
        label: Text(
          teks ?? '-',
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
          ),
        ),
        selected: false,
        onSelected: (value) {
          ontap!(teks ?? '-');
        },
        padding: EdgeInsets.zero,
        side: const BorderSide(
          color: Colors.transparent,
          width: 0,
        ),
        backgroundColor: Colors.green,
        shape: const StadiumBorder(),
      ),
    );
  }
}
