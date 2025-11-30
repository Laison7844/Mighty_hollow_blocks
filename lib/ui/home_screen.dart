import 'package:flutter/material.dart';
import 'package:flutter_projects/core/constants/constants.dart';
import 'package:flutter_projects/model/inventory_model.dart';
import 'package:flutter_projects/ui/add_stocks.dart';
import 'package:flutter_projects/ui/customer_screen.dart';
import 'package:flutter_projects/ui/customs/appbar.dart';
import 'package:flutter_projects/ui/customs/button.dart';
import 'package:flutter_projects/ui/order_screen.dart';
import 'package:flutter_projects/ui/production_screen.dart';
import 'package:flutter_projects/ui/settings.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
   HomeScreen({super.key});
  
static String path="/home_screen";
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


 int _selectedIndex = 0;

  final List<String> _routes = [
    HomeScreen.path,
    ProductionScreen.path,
    OrdersScreen.path,
    CustomerScreen.path,
    SettingsScreen.path
  ];


  @override
  Widget build(BuildContext context) {
    final inv = InventoryModel(type: 6, totalCount: 120);
 
    return Scaffold(
      appBar:CustomAppBar( title: 'Inventory',),
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
        
          children:
          [
            SizedBox(height: 20,),
            Text("Current Stock Status",style: TextStyle(
          fontSize: 24,fontWeight: FontWeight.w700,
        )),
         SizedBox(height: 10,),
             buildInventoryCard(title: "joi",type:4,units: 100),
          buildInventoryCard(title: "joi",type:6,units: 2000),
          buildInventoryCard(title: "joi",type:8,units: 100),
          SizedBox(height: 10,),
          CustomButton(icon: Icon(Icons.import_contacts),
          name: "New Stock Movement",onTap: (){},
          )
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

 _bottomNavigationBar(){
return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          context.go(_routes[index]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
         
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      );
  
 }


 Widget buildInventoryCard({
  required String title,
  required int type,
  required int units,
}) {
  Color color=type==4?const Color.fromARGB(255, 5, 47, 119):type==6?const Color.fromARGB(255, 14, 164, 19):const Color.fromARGB(255, 171, 155, 13);
  String name =type==4?Constants.type4:type==6?Constants.type6:Constants.type8;
  return Container(
    height:180,
    margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: color,
          blurRadius: 10,
          offset: const Offset(0, 9),
          spreadRadius: 0
        ),
      ],
      border: Border.all(
        color: const Color(0xffe2e8f0),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)
                ),
              
              child: Text(
               "$title ($name)",
                style:  TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
             Icon(
              Icons.layers,
              color:color,
              size: 30,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Main Units
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              units.toString(),
              style:  TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "units",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),
        Divider(height: 2,indent: 10,endIndent: 10,),
        const SizedBox(height: 10),

        // Bottom Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            units<250?
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Low Stock: ${units-500}",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ):Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Stable",
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

            GestureDetector(
              onTap: (){
                context.go(AddStocks.path);
              },
              child: const Text(
                "Add Stock",
                style: TextStyle(
                  color: Color(0xff2563eb),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


}