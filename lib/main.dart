import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Finapp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TransactionController _controller = Get.put(TransactionController());

  @override
  void initState() {
    super.initState();
    _controller.fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finapp!'),
        bottom: TabBar(
          controller: _controller.tabController,
          tabs: const [
            Tab(text: 'In'),
            Tab(text: 'Log'),
            Tab(text: 'Out'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller.tabController,
        children: const [
          TransactionList(type: 'in'),
          TransactionList(type: 'log'),
          TransactionList(type: 'out'),
        ],
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  final String type;

  const TransactionList({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionController>(
      builder: (controller) {
        final transactions =
            controller.transactions.where((t) => t['type'] == type).toList();
        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return ListTile(
              title: Text(transaction['category']),
              subtitle: Text(transaction['description']),
              trailing: Text(transaction['amount']),
            );
          },
        );
      },
    );
  }
}

class TransactionController extends GetxController
    with SingleGetTickerProviderMixin {
  late TabController tabController;
  var transactions = [].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
  }

  void fetchTransactions() async {
    try {
      var response = await Dio().get('http://103.59.160.126:9102');
      if (response.statusCode == 200) {
        transactions.value = response.data['data'];
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }
}
