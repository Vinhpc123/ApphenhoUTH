import 'package:flutter/material.dart';
import 'screens/facebook_login.dart'; // Import màn hình đăng nhập
import 'package:apphenhouth/main.dart.dart'; // Import màn hình chính

void main() {
  runApp(MaterialApp(
    home: FacebookLoginScreen(), // Đặt màn hình FacebookLoginScreen làm màn hình đầu tiên
  ));
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UTHLove(),
    );
  }
}

class UTHLove extends StatefulWidget {
  @override
  _UTHLoveState createState() => _UTHLoveState();
}

class _UTHLoveState extends State<UTHLove> {
  List<String> profiles = ["Rex, 27", "John, 24", "Sam, 22"];
  int currentProfileIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UTH Love'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return FilterDialog();
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Stack(
          children: [
            // Backdrop for swipeable cards
            for (int i = 0; i < profiles.length; i++)
              Positioned(
                top: 20.0,
                left: 20.0,
                right: 20.0,
                child: i == currentProfileIndex
                    ? Card(
                  elevation: 5.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          profiles[i],
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '5 miles',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
                    : SizedBox.shrink(),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  if (currentProfileIndex < profiles.length - 1) {
                    currentProfileIndex++;
                  }
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
                setState(() {
                  if (currentProfileIndex < profiles.length - 1) {
                    currentProfileIndex++;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FilterDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filter'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Distance'),
            items: ['0-10 km', '10-20 km', '20-30 km']
                .map((distance) => DropdownMenuItem(
              value: distance,
              child: Text(distance),
            ))
                .toList(),
            onChanged: (value) {},
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text('Gender: '),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChoiceChip(label: Text('Male'), selected: false),
                    ChoiceChip(label: Text('Female'), selected: false),
                  ],
                ),
              ),
            ],
          ),
          Slider(
            min: 18,
            max: 60,
            value: 22,
            onChanged: (double value) {},
            label: 'Age: 22',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Apply'),
        ),
      ],
    );
  }
}
