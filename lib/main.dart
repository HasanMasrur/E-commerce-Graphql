import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const productGraphQL = """ 
query products{ products(first: 50, channel: "default-channel") {
    edges {
      node {
        id
        name
        description
        thumbnail {
          url
        }
      }
    }
  }
  }
""";

void main() {
  final HttpLink httpLink = HttpLink('https://demo.saleor.io/graphql/');
  ValueNotifier<GraphQLClient> client = ValueNotifier(GraphQLClient(
      link: httpLink, cache: GraphQLCache(store: InMemoryStore())));
  var app = GraphQLProvider(
    client: client,
    child: const MyApp(),
  );
  runApp(app);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Product Show using Graphql'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Query(
            options: QueryOptions(document: gql(productGraphQL)),
            builder: (QueryResult result, {fetchMore, refetch}) {
              if (result.hasException) {
                return Text(result.exception.toString());
              }
              if (result.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.red),
                );
              }
              final productList = result.data?['products']['edges'];
              return Column(
                children: [
                  Expanded(
                      child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemCount: productList.length,
                          itemBuilder: (context, index) {
                            final data = productList[index]['node'];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child:
                                        Image.network(data['thumbnail']['url']),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                          productList[index]['node']['name'])),
                                ],
                              ),
                            );
                          }))
                ],
              );
            }));
  }
}
