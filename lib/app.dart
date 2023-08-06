import 'package:budget_tracker_2/auth.dart';
import 'package:budget_tracker_2/expense_notes.dart';
import 'package:budget_tracker_2/bar_chart.dart';
import 'package:flutter/material.dart';
import 'expenses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'expense_history.dart';


void main() => runApp(MaterialApp(
  home: const Home(),
  routes: {
    '/budget': (context) => const Budget(),
  }, ),
);

class MyPopupDialog extends StatefulWidget {
  final BuildContext context;
  final Function(String category, String name, int price, DateTime date, String notes) onExpenseAdded;

  const MyPopupDialog({super.key, required this.context, required this.onExpenseAdded});

  @override
  _MyPopupDialogState createState() => _MyPopupDialogState();
}

class _MyPopupDialogState extends State<MyPopupDialog> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Income';
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.deepPurple,
      title: const Text('New expense',
        style: TextStyle(
          fontFamily: 'RobotoSlab',
          fontSize: 20,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Category : ',
                style: TextStyle(
                  fontFamily: 'RobotoSlab',
                  fontSize: 15,
                  color: Colors.white,
                )),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
              items: <String>['Income', 'Expenses', 'Gifts/Received Money', 'Other']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            const Text('Name : ',
                style: TextStyle(
                  fontFamily: 'RobotoSlab',
                  fontSize: 15,
                  color: Colors.white,
                )),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                fillColor: Colors.deepPurpleAccent,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Price : ',
                style: TextStyle(
                  fontFamily: 'RobotoSlab',
                  fontSize: 15,
                  color: Colors.white,
                )),
            const SizedBox(height: 10),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                fillColor: Colors.deepPurpleAccent,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Date : ',
                style: TextStyle(
                  fontFamily: 'RobotoSlab',
                  fontSize: 15,
                  color: Colors.white,
                )),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
                  });
                }
              },
              child: Text(
                DateFormat('yyyy-MM-dd').format(_selectedDate),
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Notes : ',
                style: TextStyle(
                  fontFamily: 'RobotoSlab',
                  fontSize: 15,
                  color: Colors.white,
                )),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notesController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                fillColor: Colors.deepPurpleAccent,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () async {
            try {
              String category = _selectedCategory;
              String name = _nameController.text;
              int price = int.tryParse(_priceController.text) ?? 0;
              DateTime date = _selectedDate;
              String notes = _notesController.text;

              if (name.isNotEmpty && price != 0) {

                widget.onExpenseAdded(category, name, price, date, notes);

                Navigator.of(context)
                    .pop();
              } else {
                showDialog(
                  context: context,
                  builder: (context) =>
                      AlertDialog(
                        title: const Text('Error'),
                        content: const Text(
                            'Please enter valid name and price.'),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                );
              }
            } catch (e) {
              print('Error adding expense: $e');
            }
          },
          icon: const Icon(
            Icons.check_box,
            size: 30,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Future<void> _signOut(BuildContext context) async {
    try {
      await Auth().signOut();
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
            (route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  double calculateTotalSum(List<Expenses> expenses) {
    double sum = 0.0;
    for (var expense in expenses) {
      sum += expense.price;
    }
    return sum;
  }

  late double _totalSum = 0.0;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      CollectionReference userExpensesRef = FirebaseFirestore.instance.collection('users').doc(Auth().currentUser!.uid).collection('expenses');

      QuerySnapshot querySnapshot = await userExpensesRef.get();

      double newTotalSum = calculateTotalSum(querySnapshot.docs
          .map((doc) => Expenses(
        id: doc.id,
        category: doc['category'],
        name: doc['name'],
        price: doc['price'],
        date: doc['date'].toDate(),
        notes: doc['notes'],
      ))
          .toList());

      setState(() {
        _totalSum = newTotalSum;
      });
    } catch (e) {
      print('Error loading expenses: $e');
    }
  }

  Future<void> _updateTotal() async {
    _loadExpenses();
  }

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
          const SizedBox(height: 20,),
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
          const SizedBox(height: 70,),
          Center(
              child: TextButton.icon(
                  onPressed: (){
                    Navigator.pushNamed(context, '/budget', arguments: _updateTotal);
                  },
                  label: Text('Total:    ${_totalSum.toStringAsFixed(2)}',
                      style: const TextStyle(
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
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _signOut(context),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.blue; // Color when pressed
                  }
                  return Colors.amber; // Default color
                }),
              ),
            child: const Text('Sign Out',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),)),
        ],
      ),
    );
  }
}

class BudgetList extends StatefulWidget {
  final Expenses element;
  const BudgetList({super.key, required this.element});

  @override
  State<BudgetList> createState() => _BudgetListState();
}

class _BudgetListState extends State<BudgetList> {
  void _deleteExpense() async {
    try {
      CollectionReference userExpensesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(Auth().currentUser!.uid).collection('expenses');

      await userExpensesRef.doc(widget.element.id).delete();

      _BudgetState budgetState = context.findAncestorStateOfType<_BudgetState>()!;
      budgetState._loadExpenses();

      final Function updateTotal = ModalRoute
          .of(context)!
          .settings
          .arguments as Function;
      updateTotal();
    } catch (e) {
      print('Error deleting expense: $e');
    }
  }

  void _editExpense(int priceDifference, DateTime newDate, String newNotes) async {
    try {
      CollectionReference userExpensesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(Auth().currentUser!.uid)
          .collection('expenses');

      int newPrice = widget.element.price + priceDifference;
      String finalNotes = '${widget.element.notes ?? ''}\n$newNotes';

      List<Map<String, dynamic>> updatedHistory = [];
      updatedHistory.addAll(
          widget.element.history.map((record) => record.toMap()));

      final record = ExpenseRecord(
        date: newDate,
        price: priceDifference,
        expenseId: widget.element.id,
      );

      updatedHistory.add(record.toMap());

      await userExpensesRef.doc(widget.element.id).update({
        'price': newPrice,
        'date': newDate,
        'notes': finalNotes,
        'history': updatedHistory,
      });

      _BudgetState budgetState = context.findAncestorStateOfType<
          _BudgetState>()!;
      budgetState._loadExpenses();

      final Function updateTotal = ModalRoute
          .of(context)!
          .settings
          .arguments as Function;
      updateTotal();

      setState(() {
        widget.element.price = newPrice;
        widget.element.date = newDate;
        widget.element.notes = finalNotes;
        widget.element.history.add(record);
      });
    } catch (e) {
      print('Error editing price and date: $e');
    }
  }

  Future<void> _showEditPriceDialog(BuildContext context) async {
    int newPriceDifference = 0;
    DateTime newDate = DateTime.now();
    String newNotes = " ";

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Price and Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newPriceDifference = int.tryParse(value) ?? 0;
                },
                decoration: const InputDecoration(
                    labelText: 'Price Difference'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                onChanged: (value) {
                  newNotes = value;
                },
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: newDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      newDate = DateTime(
                          pickedDate.year, pickedDate.month, pickedDate.day);
                    });
                  }
                },
                child: Text(
                  DateFormat('yyyy-MM-dd').format(newDate),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _editExpense(newPriceDifference, newDate, newNotes);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 250,
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
                    '${widget.element.price}',
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
            onPressed: () {
              _deleteExpense();
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.black,
              size: 20,
            ),
          ),
          IconButton(
            onPressed: () {
              _showEditPriceDialog(context);
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.black,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}


class Budget extends StatefulWidget {
  const Budget({super.key});

  @override
  _BudgetState createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {

  List<Expenses> expenses = [];
  Map<String, List<Expenses>> categoryExpensesMap = {};

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      CollectionReference userExpensesRef = FirebaseFirestore.instance.collection('users').doc(Auth().currentUser!.uid).collection('expenses');

      QuerySnapshot querySnapshot = await userExpensesRef.get();

      List<Expenses> loadedExpenses = querySnapshot.docs.map((doc) {
        List<dynamic> historyData = doc['history'] ?? [];
        List<ExpenseRecord> history = historyData.map((record) => ExpenseRecord(
          date: record['date'].toDate(),
          price: record['price'],
          expenseId: doc.id,
        )).toList();

        return Expenses(
          id: doc.id,
          category: doc['category'],
          name: doc['name'],
          price: doc['price'],
          date: doc['date'].toDate(),
          notes: doc['notes'],
          history: history,
        );
      }).toList();

      setState(() {
        expenses = loadedExpenses;

        categoryExpensesMap = {};

        for (var expense in expenses) {
          if (!categoryExpensesMap.containsKey(expense.category)) {
            categoryExpensesMap[expense.category] = [];
          }
          categoryExpensesMap[expense.category]!.add(expense);
        }
      });
    } catch (e) {
      print('Error loading expenses: $e');
    }
  }




  void addExpense(String category, String name, int price, DateTime date, String notes) async {
    try {
      CollectionReference userExpensesRef = FirebaseFirestore.instance.collection('users').doc(Auth().currentUser!.uid).collection('expenses');

      final record = {
        'date': date,
        'price': price,
      };

      await userExpensesRef.add({
        'category': category,
        'name': name,
        'price': price,
        'date': date,
        'notes': notes,
        'history': [record],
      });

      _loadExpenses();

      final Function updateTotal = ModalRoute.of(context)!.settings.arguments as Function;
      updateTotal();

    } catch (e) {
      print('Error adding expense: $e');
    }
  }

  Map<String, double> calculateSpendingPercentages(List<Expenses> expenses) {
    Map<String, double> categoryPercentages = {};

    double totalSpending = expenses
        .where((expense) => expense.category == "Expenses")
        .fold(0.0, (sum, expense) => sum - expense.price);

    for (var expense in expenses) {
      if (expense.category == "Expenses") {
        if (!categoryPercentages.containsKey(expense.name)) {
          categoryPercentages[expense.name] = 0.0;
        }
        categoryPercentages[expense.name] =
            ((categoryPercentages[expense.name] ?? 0.0) - (expense.price / totalSpending))*100;
      }
    }

    return categoryPercentages;
  }

  List<ExpenseCategory> getExpenseCategories(List<Expenses> expenses) {
    Map<String, double> categoryPercentages = calculateSpendingPercentages(expenses);

    List<ExpenseCategory> expenseCategories = categoryPercentages.entries.map((entry) {
      return ExpenseCategory(name: entry.key, percentage: entry.value);
    }).toList();

    return expenseCategories;
  }



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
                itemCount: categoryExpensesMap.length,
                itemBuilder: (context, index) {
                  String category = categoryExpensesMap.keys.elementAt(index);
                  List<Expenses> expenses = categoryExpensesMap[category]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (expenses.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      for (var expense in expenses)
                        BudgetList(element: expense),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _loadExpenses();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExpenseHistoryPage(expenses: expenses),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.blueAccent; // Color when pressed
                  }
                  return Colors.amber; // Default color
                }),
              ),
              child: const Text('View Expense History',
                style: TextStyle(color: Colors.black),),
            ),
            ElevatedButton(
              onPressed: () async {
                await _loadExpenses();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExpenseNotesPage(expenses: expenses),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.blueAccent; // Color when pressed
                  }
                  return Colors.amber; // Default color
                }),
              ),
              child: const Text(' View Expense Notes ',
                style: TextStyle(color: Colors.black),),
            ),
            ElevatedButton(
              onPressed: () async {
                await _loadExpenses();
                List<ExpenseCategory> expenseCategories = getExpenseCategories(expenses);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BarChartPage(categories: expenseCategories),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.blueAccent; // Color when pressed
                  }
                  return Colors.amber; // Default color
                }),
              ),
              child: const Text('      View Bar Chart      ',
                  style: TextStyle(color: Colors.black),),
            ),

          ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(
            context: context,
            builder: (context) {
              return MyPopupDialog(
                context: context,
                onExpenseAdded: addExpense,);
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