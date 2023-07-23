import 'package:flutter/material.dart';
import 'expenses.dart';
void main() => runApp(
      MaterialApp(
          home: const Home(),
          routes: {
          '/budget': (context) => const Budget(), // Define the route for the Budget page
          },),
    );

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker',
            style: TextStyle(
              fontSize: 35.0,
              letterSpacing: 0.5,
              color: Colors.black,
              fontFamily: 'RobotoSlab',
            ),
            ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent[100],
      ),
      backgroundColor: Colors.deepPurpleAccent[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: const Icon(
                Icons.account_circle,
                size: 100.0,
              ),
            ),
          ),
          const Center(
            child: Text('Welcome',
                style: TextStyle(
                  fontSize: 30.0,
                  fontFamily: 'RobotoSlab',
                )
            ),
          ),
          const Center(
            child: Text('Back!',
                style: TextStyle(
                  fontSize: 30.0,
                  fontFamily: 'RobotoSlab',
                )),
          ),
          const SizedBox(height: 100,),
          Center(
            child: TextButton.icon(
                onPressed: (){
                  Navigator.pushNamed(context, '/budget');
                },
                label: const Text('Total:    71850',
                  style: TextStyle(
                    fontSize: 25.0,
                    fontFamily: 'Roboto',
                    color: Colors.black,
                  )),
                icon: const Icon(Icons.keyboard_double_arrow_down,
                  color: Colors.black,),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.deepPurple[50],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            )
            )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        backgroundColor: Colors.white,
        child: Icon(Icons.add,
        color: Colors.deepPurpleAccent[100],
        size: 40,),
      ),
    );
  }
}

class Exp_list extends StatefulWidget {
  final Expenses element;
  Exp_list({super.key, required this.element});

  @override
  State<Exp_list> createState() => _Exp_listState();
}

class _Exp_listState extends State<Exp_list> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
            Container(
              width: 350,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.deepPurple[50],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.element.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'RobotoSlab',
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${widget.element.amount}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'RobotoSlab',
                      color: Colors.black,
                    ),
                  ),
                ]
              ),
            ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.delete,
              color: Colors.black,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class MyPopupDialog extends StatelessWidget {
  const MyPopupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.deepPurple,
      title: const Text('New expense',
        style: TextStyle(
          fontFamily:'RobotoSlab',
          fontSize: 20,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
        ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category : ',
              style: TextStyle(
                fontFamily:'RobotoSlab',
                fontSize: 15,
                color: Colors.white,
              )),
          SizedBox(height: 10),
          Text('Price : ',
              style: TextStyle(
                fontFamily:'RobotoSlab',
                fontSize: 15,
                color: Colors.white,
              )),
          SizedBox(height: 10),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.check_box,
          size: 30,
          color: Colors.white,),
        ),
      ],
    );
  }
}


class Budget extends StatefulWidget {
  const Budget({super.key});

  @override
  _BudgetState createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {

  List<Expenses> expenses = [
    Expenses(name: 'Salary', amount: 75000),
    Expenses(name: 'Electricity', amount: -1000),
    Expenses(name: 'Groceries', amount: -1500),
    Expenses(name: 'Mobile Recharge', amount: -400),
    Expenses(name: 'Movie', amount: -250),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker',
          style: TextStyle(
            fontSize: 35.0,
            letterSpacing: 0.5,
            color: Colors.black,
            fontFamily: 'RobotoSlab',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent[100],
      ),
      backgroundColor: Colors.deepPurpleAccent[100],
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                return Center(child: Exp_list(element: expenses[index]));
              },
            ),
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(
            context: context,
            builder: (context) {
              return const MyPopupDialog(); // Your custom dialog widget goes here
            },
          );
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.add,
          color: Colors.deepPurpleAccent[100],
          size: 40,),
      ),
    );
  }
}

