import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseProvider with ChangeNotifier {
  double _total = 0;
  List<Expense> _expenses = [];

  double get total => _total;
  List<Expense> get expenses => _expenses;

  void addExpense(Expense expense) {
    _expenses.add(expense);
    _total += expense.amount;
    notifyListeners();
  }

  void removeExpense(Expense expense) {
    _expenses.remove(expense);
    _total -= expense.amount;
    notifyListeners();
  }
}

class Expense {
  final String category;
  final double amount;

  Expense({required this.category, required this.amount});
}

class BudgetTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider(),
      child: MaterialApp(
        title: 'Budget Tracker',
        home: HomeScreen(),
        routes: {
          '/expense': (context) => ExpenseScreen(),
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final total = expenseProvider.total;

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
            ],
          ),
        ),
      ),
    );
  }
}

class ExpenseScreen extends StatelessWidget {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  void addExpense(BuildContext context) {
    final category = categoryController.text.trim();
    double amount = double.tryParse(amountController.text.trim()) ?? 0.0;

    if (category.isNotEmpty && amount != 0) {
      final expense = Expense(category: category, amount: amount);
      Provider.of<ExpenseProvider>(context, listen: false).addExpense(expense);

      categoryController.clear();
      amountController.clear();
    }
  }

  void deleteExpense(BuildContext context, Expense expense) {
    Provider.of<ExpenseProvider>(context, listen: false).removeExpense(expense);
  }

  Future<void> openDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //contentPadding: EdgeInsets.all(20.0),
        title: Center(
            child:Text('New Entry',
        style:TextStyle(
          color: Colors.pink,
          fontSize: 28,
            fontFamily: 'Lumanosimo'
        ))),

        content: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
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
                    borderSide: BorderSide(color: Colors.black,width:3.0),
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
                    borderSide: BorderSide(color: Colors.black,width:3.0),
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
              addExpense(context); // Call the addExpense method with the context
              Navigator.pop(context); // Close the dialog after adding the expense
            },
            child: Icon(Icons.done_outline_rounded),
          ),
        ],
      ),
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
              Card(
                child: ListTile(
                  title: Text(
                    'Balance: ',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  trailing: Consumer<ExpenseProvider>(
                    builder: (context, expenseProvider, _) => Text(
                      expenseProvider.total.toString(),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: expenseProvider.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenseProvider.expenses[index];
                    return ExpenseCard(
                      expense: expense,
                      onDelete: () => deleteExpense(context, expense),
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
  final VoidCallback onDelete;

  const ExpenseCard({
    required this.expense,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          expense.category,
          style: TextStyle(
            color: Colors.pink,
            fontFamily: 'Lugrasimo',
            fontSize: 20,
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
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(BudgetTrackerApp());
}
