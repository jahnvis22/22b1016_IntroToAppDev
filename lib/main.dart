
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loginscreen.dart';
import 'package:intl/intl.dart';


class TopNewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo,
            offset: Offset(0,4),
            blurRadius: 12.0, // Increase the blurRadius for a deeper shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'BALANCE',
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontFamily: 'Lugrasimo',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Consumer<ExpenseProvider>(
            builder: (context, expenseProvider, _) => Text(
              '${expenseProvider.total.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Icon(Icons.arrow_upward, color: Colors.green),
                  Text(
                    'Income',
                    style: TextStyle(
                      color: Colors.green,
                      fontFamily: 'Lugrasimo',
                      fontSize: 18,
                    ),
                  ),
                  Consumer<ExpenseProvider>(
                    builder: (context, expenseProvider, _) => Text(
                      '${expenseProvider._totincome.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.arrow_downward, color: Colors.red),
                  Text(
                    'Expenses',
                    style: TextStyle(
                      color: Colors.red,
                      fontFamily: 'Lugrasimo',
                      fontSize: 18,
                    ),
                  ),
                  Consumer<ExpenseProvider>(
                    builder: (context, expenseProvider, _) => Text(
                      '${expenseProvider._totexpenses.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExpenseDatabase {
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.ref();
  final String _userId;

  ExpenseDatabase(this._userId);

  void addExpense(Expense expense) {
    final newExpenseRef = _databaseReference
        .child('users')
        .child(_userId)
        .child('expenses')
        .push();
    newExpenseRef.set({
      'category': expense.category,
      'amount': expense.amount,
      'date':expense.date.toIso8601String(),
    });
  }

  void removeExpense(String expenseKey) {
    _databaseReference
        .child('users')
        .child(_userId)
        .child('expenses')
        .child(expenseKey)
        .remove();
  }
}


class ExpenseProvider with ChangeNotifier {
  double _total = 0;
  double _totexpenses = 0;
  double _totincome= 0;
  List<Expense> _expenses = [];

  double get total => _total;
  List<Expense> get expenses => _expenses;

  final ExpenseDatabase _expenseDatabase;

  ExpenseProvider(this._expenseDatabase);

  void addExpense(Expense expense) {
    _expenses.add(expense);
    _total += expense.amount;
    if (expense.amount>0){
      _totincome+=expense.amount;
    }
    else{
      _totexpenses+=(-1)*expense.amount;
    }
    _expenseDatabase.addExpense(expense); // Update Firebase Database
    notifyListeners();
  }

  void removeExpense(Expense expense, String expenseKey) {
    _expenses.remove(expense);
    _total -= expense.amount;
    if (expense.amount>0){
      _totincome-=expense.amount;
    }
    else{
      _totexpenses-=(-1)*expense.amount;
    }
    _expenseDatabase.removeExpense(expenseKey); // Update Firebase Database
    notifyListeners();
  }
}

class Expense {
  final String category;
  final double amount;
  final DateTime date;

  Expense({required this.category, required this.amount,required this.date});
}

class BudgetTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          // Get the user ID
          final userId = snapshot.data!.uid;

          // Create an instance of ExpenseDatabase
          final expenseDatabase = ExpenseDatabase(userId);

          return ChangeNotifierProvider(
            create: (_) => ExpenseProvider(expenseDatabase),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Budget Tracker',
              home: HomeScreen(),
              routes: {
                '/expense': (context) => ExpenseScreen(),
              },
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Budget Tracker',
          home: LoginScreen(),
        );
      },
    );
  }
}


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Budget Tracker Home Page',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black54,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            colors: [Colors.cyanAccent, Colors.lightBlue],
            radius: 1,
            tileMode: TileMode.clamp,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.account_circle_sharp,
                size: 250,
              ),
              Text(
                'Welcome Back User!',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontFamily: 'Lumanosimo',
                    fontWeight: FontWeight.bold
                ),
              ),
              Card(
                child: ListTile(
                  title: Row(
                    children: [
                      Text(
                        'Balance: ',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Consumer<ExpenseProvider>(
                        builder: (context, expenseProvider, _) => Text(
                          expenseProvider.total.toString(),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),

                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.pushNamed(context, '/expense');
                  },
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();},
                child: const Text(
                    'Logout'
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ExpenseScreen extends StatefulWidget {
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final TextEditingController categoryController = TextEditingController();

  final TextEditingController amountController = TextEditingController();

  bool _isIncome = false;
  DateTime dateTime = DateTime.now();

  void _showDatePicker(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (selectedDate != null) { // Check if a date was selected
      setState(() {
        dateTime = selectedDate; // Step 2: Update the dateTime variable
      });
    }
  }
  void addExpense(BuildContext context) {
    final category = categoryController.text.trim();
    double amount = double.tryParse(amountController.text.trim()) ?? 0.0;

    if (!_isIncome) {
      amount *= -1;
    }

    if (category.isNotEmpty && amount != 0) {
      final expense = Expense(category: category, amount: amount,date:dateTime);
      Provider.of<ExpenseProvider>(context, listen: false).addExpense(expense);

      categoryController.clear();
      amountController.clear();
    }
  }

  void deleteExpense(BuildContext context, Expense expense, String expenseKey) {
    Provider.of<ExpenseProvider>(context, listen: false).removeExpense(
        expense, expenseKey); // Pass both the expense and the key
  }

  Future<void> openDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context)
    {
      return StatefulBuilder(
        builder: (BuildContext context,setState) {
          return AlertDialog(

            //contentPadding: EdgeInsets.all(20.0),
            title: Center(
                child: Text('New Entry',
                    style: TextStyle(
                        color: Colors.pink,
                        fontSize: 28,
                        fontFamily: 'Lumanosimo'
                    ))),

            content: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Expense',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight:FontWeight.bold,

                      ),),
                      Switch(value: _isIncome,
                          onChanged: (newvalue) {
                            setState(() {
                              _isIncome = newvalue;
                            });
                          }),
                      Text('Income',
                       style: TextStyle( fontFamily: 'Montserrat',
                        fontWeight:FontWeight.bold,))
                    ],
                  ),
                  StatefulBuilder(
                    builder: (BuildContext context, setState) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                            ElevatedButton(
                              onPressed: () => _showDatePicker(context),
                              style: ElevatedButton.styleFrom(
fixedSize: const Size(100,40),
                              foregroundColor: Colors.white, backgroundColor: Colors.purple, // Set the text color
                              elevation: 4, // Set the elevation (shadow) of the button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Set the border radius
                              ),
                            ),
                            child:  Text(
                                'Choose Date',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Montserrat',

                              ),
                            ),
                          ),
                                                 Center(
                                child: Text(
                                    DateFormat('dd-MM-yyyy').format(dateTime).toString(),
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.blue,
                                    fontSize: 15, // Adjust the font size of the date display
                                  ),
          )
          ),

                        ],
                      );
                    }
                  ),

                  TextField(
                    controller: categoryController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(
                          color: Colors.purple,
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Montserrat'
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 3.0),
                        borderRadius: BorderRadius.all(Radius.circular(30)),

                      ),
                      filled: true,
                      fillColor: Colors.white30,
                    ),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(
                          color: Colors.purple,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Montserrat'
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 3.0),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      filled: true,
                      fillColor: Colors.white30,
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              FloatingActionButton(
                onPressed: () {
                  addExpense(
                      context); // Call the addExpense method with the context
                  Navigator.pop(
                      context); // Close the dialog after adding the expense
                },
                child: Icon(Icons.done_outline_rounded),
              ),
            ],
          );
        }
        );

      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black54,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.cyan[200],
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              TopNewCard(),
              // Card(
              //   child: ListTile(
              //     title: Text(
              //       'Balance: ',
              //       style: TextStyle(
              //         fontFamily: 'Montserrat',
              //         fontWeight: FontWeight.bold,
              //         fontSize: 18,
              //       ),
              //     ),
              //     trailing: Consumer<ExpenseProvider>(
              //       builder: (context, expenseProvider, _) => Text(
              //         expenseProvider.total.toString(),
              //         style: TextStyle(
              //           fontFamily: 'Montserrat',
              //           fontWeight: FontWeight.bold,
              //           fontSize: 18,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              Expanded(
                child: ListView.builder(
                  itemCount: expenseProvider.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenseProvider.expenses[index];
                    final expenseKey = ''; // Get the expense key here from your Firebase Database
                    return ExpenseCard(
                      expense: expense,
                      onDelete: (BuildContext context) => deleteExpense(context, expense, expenseKey), // Pass both the expense and the key
                    );
                  },
                ),
              ),

            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openDialog(context); // Call the openDialog method with the context
        },
        child: Icon(Icons.add),
      ),

    );
  }
}

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  void Function(BuildContext)? onDelete;

  ExpenseCard({
    required this.expense,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: onDelete,
            backgroundColor: Colors.red,
            icon: Icons.delete,
          ),
        ],
      ),
      child: Card(
        color:Colors.white.withOpacity(0.9),
        child: ListTile(
        title: Text(
          expense.category,
          style: TextStyle(
            color: Colors.pink,
            fontFamily: 'Lugrasimo',
            fontSize: 20,
          ),
        ),
    subtitle: Text(
    DateFormat('dd MMM yyyy').format(expense.date),
      style: TextStyle(
        color: Colors.grey,
        fontSize: 14,
      ),
    ),
    trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${expense.amount}',
              style: TextStyle(
                color: Colors.purpleAccent,
                fontFamily: 'Lugrasimo',
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(

  );
  runApp(BudgetTrackerApp());
}