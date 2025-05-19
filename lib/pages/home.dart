import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  File? _image;
  String? _result;
  final ImagePicker _picker = ImagePicker();

  //function used to Pick Image form library or camera depending upon souce in the picImage() paramter
  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        Navigator.pop(context);
        _image = File(pickedFile.path);
      });
    }
  }

  //function used to send image file along with prompt to get required output
  Future<void> _sendToGemini(File imageFile) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY']; //load api key form .env file
      final base64Image = base64Encode(
        await imageFile.readAsBytes(),
      ); //convert image to bytes

      //this is the url to connect to gemini model
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey', //api key is also passed along with api url
      );

      // jsonEncoded data is required to send to server post method
      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Identify the fish in this photo and provide without any greeting message in beigning:\nFish name\nOrigin\nMacronutrients per 100g\nAdvantages\nDisadvantages",
              },
              {
                "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
              },
            ],
          },
        ],
      });

      final headers = {"Content-Type": "application/json"};
      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      ); // this is the http post request send to server the resposne is the result

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          _result = text;
        });
      } else if (response.statusCode == 503) {
        setState(() {
          _result = 'Sorry AI model gets overloaded.. Please try again..';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Unexpected error occured';
      });
    }
  }

  //function to show a progress bar api is called and fetch response
  Future<void> _showProgress(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Image Processing')),
          content: Column(
            spacing: 5,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please wait while processing image..'),
              SizedBox(width: 100, child: LinearProgressIndicator()),
            ],
          ),
        );
      },
    );
  }

  //this is the function to show a bottom model sheet to allow user to choose the image souce, if it is from gallery or camera
  _imagePickOptions(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * .2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                spacing: 5,
                children: [
                  SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  Text(
                    'Choose image Options',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      label: Text('From gallery'),
                      icon: Icon(Icons.image),
                      onPressed: () {
                        _pickImage(ImageSource.gallery, context);
                      },
                    ),
                    ElevatedButton.icon(
                      label: Text('Open Camera'),
                      icon: Icon(Icons.camera_alt),
                      onPressed: () {
                        _pickImage(ImageSource.camera, context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // this is the override build function the UI of the screen are viewed
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _image != null
              ? Expanded(
                flex: _result != null ? 1 : 2,
                child: Image.file(_image!, fit: BoxFit.contain),
              )
              : Expanded(flex: 2, child: Lottie.asset("assets/anim/fish.json")),
          SizedBox(height: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,

            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.image),
                  onPressed: () {
                    setState(() {
                      _result = null;
                    });
                    _imagePickOptions(context);
                  },
                  label: Text(
                    _image != null ? "Change Fish Image" : "Select Fish Image",
                  ),
                ),
              ),

              if (_image != null && _result == null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: Text('OR')),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.image_search_outlined),
                        onPressed: () async {
                          _showProgress(context);
                          await _sendToGemini(_image!);
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                        label: Text("Identify The Fish"),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(style: TextStyle(fontSize: 20), _result ?? ''),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
