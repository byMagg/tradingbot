import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 4,
                        offset: Offset(0, 0), // changes position of shadow
                      ),
                    ],
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('lib/assets/user.jpg'),
                    )),
              ),
            ),
          ),
          Text(
            "Hi, Dani!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: MaterialButton(
              child: Text("Notifications"),
              onPressed: () {},
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: MaterialButton(
              child: Text("Your Account"),
              onPressed: () {},
            ),
          ),
          Divider(
            thickness: 1,
            indent: 50,
            endIndent: 50,
            color: Colors.black,
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: MaterialButton(
              child: Text("Privacy & Security"),
              onPressed: () {},
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: MaterialButton(
              child: Text("Terms & Conditions"),
              onPressed: () {},
            ),
          ),
          ListTile(
            title: MaterialButton(
              color: Colors.redAccent,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.logout), Text("Log out")]),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }
}
