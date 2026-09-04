import 'package:flutter/material.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/widgets/angular_progress_bar.dart';
import 'package:smartlink/widgets/tappable.dart';

class SearchResults extends StatelessWidget {
    const SearchResults({
        required this.customers,
        required this.searching,
        required this.on_select,
        super.key
    });
    final List<Map> customers;
    final bool searching;
    final ValueChanged<int> on_select;

    @override
    Widget build(BuildContext context) {
        if (searching) return const Center(child: AngularProgressBar());

        if (customers.isEmpty) {
            return Center(
                child: Text(t.home.no_results, style: const TextStyle(color: AppColors.secondary))
            );
        }

        return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
                final Map customer = customers[index];
                final String label = customer['agreement'] == null? customer['name'] : '${customer['agreement']}: ${customer['name']}';

                return Tappable(
                    on_tap: () => on_select(customer['id']),
                    disable_selection: true,
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(label, style: const TextStyle(fontSize: 15))
                    )
                );
            }
        );
    }
}
