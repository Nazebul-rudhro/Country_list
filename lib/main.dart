import 'dart:convert'; // Import for JSON decoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:flutter_bloc/flutter_bloc.dart'; // Ensure you have flutter_bloc imported
import 'package:bloc/bloc.dart';

class CountryListLogic extends Cubit<Map<String, dynamic>> {
  CountryListLogic()
    : super({'loading': false, 'countries': [], 'error': null});

  void fetchCountries() async {
    // Emit loading state while fetching data
    emit({'loading': true, 'countries': [], 'error': null});

    try {
      // Fetching data from API
      final response = await http.get(
        Uri.parse("https://countrylist.teamrabbil.com/api/country-list"),
      );

      // Parse the response body (JSON)
      List<dynamic> data = json.decode(response.body);

      // Emit the loaded data into the state
      emit({'loading': false, 'countries': data, 'error': null});
    } catch (e) {
      // Emit error if there is an issue
      emit({'loading': false, 'countries': [], 'error': e.toString()});
    }
  }
}

// class CountryDetailsLogic extends Cubit {
//   CountryDetailsLogic() : super(null);

//   void goTodetailsScreen(BuildContext context, Map<String, dynamic> country) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => CountryDetailsScreen(country)),
//     );
//   }
// }

class CountryDetailsLogic extends Cubit<Map<String, dynamic>?> {
  CountryDetailsLogic() : super(null);

  void goTodetailsScreen(BuildContext context, Map<String, dynamic> country) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CountryDetailsScreen(country)),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CountryListLogic()),
        BlocProvider(create: (context) => CountryDetailsLogic()),
      ],
      child: MaterialApp(home: CountryApp()),
    );
  }
}

class CountryApp extends StatelessWidget {
  const CountryApp({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() => context.read<CountryListLogic>().fetchCountries());
    return Scaffold(
      body: BlocBuilder<CountryListLogic, Map<String, dynamic>>(
        builder: (context, data) {
          // Show loading indicator when 'loading' state is true
          if (data['loading'] == true) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (data["error"] != null) {
            return Center(
              child: Text(data["error"], style: TextStyle(color: Colors.red)),
            );
          } else {
            return ListView.builder(
              itemCount: data["countries"].length,
              itemBuilder: (context, index) {
                var country = data["countries"][index];
                return ListTile(
                  leading: Image.network(country['flag']),
                  title: Text(country['name']),
                  onTap:
                      () => context
                          .read<CountryDetailsLogic>()
                          .goTodetailsScreen(context, country),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// class CountryDetailsScreen extends StatelessWidget {
//   Map<String, dynamic> country;
//   CountryDetailsScreen(this.country);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(appBar: AppBar(Text(country['name'])));
//   }
// }

class CountryDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> country;

  CountryDetailsScreen(this.country);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(country['name'])),
      body: Center(child: Text('Details about ${country['name']}')),
    );
  }
}
