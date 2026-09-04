import 'package:flutter/material.dart';
import 'package:flutter_date_formatter/flutter_date_formatter.dart';
import 'package:smartlink/i18n.dart';
import 'package:smartlink/theme.dart';
import 'package:smartlink/utils.dart';
import 'package:smartlink/widgets/angular_progress_bar.dart';
import 'package:smartlink/widgets/data_card.dart';
import 'package:smartlink/widgets/icon_action.dart';
import 'package:smartlink/widgets/info_tile.dart';
import 'package:smartlink/widgets/sub_heading.dart';
import 'package:smartlink/widgets/tappable.dart';

class CustomerCard extends StatelessWidget {
    const CustomerCard({
        required this.customer,
        required this.building,
        required this.on_refresh,
        required this.on_open_ont,
        required this.on_new_task,
        required this.on_phone_update,
        super.key
    });
    final Map? customer;
    final Map? building;

    final VoidCallback on_refresh;
    final VoidCallback on_open_ont;
    final VoidCallback on_new_task;
    final VoidCallback on_phone_update;

    @override
    Widget build(BuildContext context) {
        return DataCard(
            line_color: get_customer_border_color(customer),
            icon: Icons.person,
            title: t.customer.title,
            mini_buttons: [
                IconAction(
                    tooltip: t.customer.ont_tooltip,
                    icon: Icons.router_outlined,
                    on_pressed: on_open_ont
                ),
                IconAction(
                    tooltip: t.customer.attachs_tooltip,
                    icon: Icons.attach_file,
                    on_pressed: null
                ),
                IconAction(
                    tooltip: t.customer.new_task_tooltip,
                    icon: Icons.assignment_add,
                    on_pressed: on_new_task
                ),
                IconAction(
                    tooltip: t.customer.open_tooltip,
                    icon: Icons.open_in_browser,
                    on_pressed: customer != null
                        ? () => open_in_userside(context, 'customer', customer!['id'])
                        : null
                ),
                IconAction(
                    tooltip: t.customer.copy_tooltip,
                    icon: Icons.copy,
                    on_pressed: customer != null
                        ? () => copy_userside_link(context, 'customer', customer!['id'])
                        : null
                ),
                IconAction(
                    tooltip: t.common.refresh,
                    icon: Icons.refresh,
                    on_pressed: customer != null? on_refresh : null
                )
            ],
            child: customer == null
                ? const Center(child: AngularProgressBar())
                : Column(
                    children: [
                        if (customer!['is_potential'] == true)
                        _Warning(icon: Icons.favorite, text: t.customer.is_potential, color: AppColors.neo),

                        if (customer!['is_corporate'] == true)
                        _Warning(icon: Icons.business, text: t.customer.is_corporate, color: AppColors.neo),

                        if (customer!['has_billing'] == false)
                        _Warning(icon: Icons.money_off_csred_outlined, text: t.customer.no_billing, color: AppColors.error),

                        if (customer!['olt_id'] == null)
                        _Warning(icon: Icons.cable, text: t.customer.not_switched, color: AppColors.warning),

                        if (customer!['status'] == 'inactive')
                        _Warning(icon: Icons.power_settings_new, text: t.customer.is_inactive, color: AppColors.error),

                        if (customer!['status'] == 'pause')
                        _Warning(icon: Icons.pause_circle_outline, text: t.customer.is_paused, color: AppColors.warning),

                        if (customer!['last_active_at'] != null && get_activity_color(customer!['last_active_at']) == AppColors.error)
                        _Warning(
                            icon: Icons.access_time,
                            text: t.customer.last_activity_warning(
                                FlutterDateFormatter.formatRelativeDateTime(parse_api_date(customer!['last_active_at'])!)
                            ),
                            color: AppColors.error
                        ),

                        if (get_building_border_color(building?['customers']) == AppColors.error)
                        _Warning(icon: Icons.build_circle_outlined, text: t.customer.building_problems, color: AppColors.error),
                        InfoTile(title: t.customer.name, value: customer!['name']),
                        InfoTile(title: t.customer.agreement, value: customer!['agreement']?['number']),
                        InfoTile(
                            title: t.customer.balance,
                            value: t.common.som('${customer!['balance']}'),
                            value_color: get_balance_color((customer!['balance'] ?? 0) as num)
                        ),
                        InfoTile(
                            title: t.customer.status,
                            value: status_label(customer!['status']),
                            value_color: get_status_color(customer!['status'])
                        ),
                        InfoTile(title: t.customer.connected_at, value: format_date(customer!['connected_at'])),
                        InfoTile(title: t.customer.group, value: customer!['group']?['name']),
                        InfoTile(
                            title: t.customer.last_activity,
                            value: format_date(customer!['last_active_at']),
                            value_color: get_activity_color(customer!['last_active_at'])
                        ),
                        const SizedBox(height: 5),
                        InfoTile(
                            title: customer!['phones'].length == 1? t.customer.phone : t.customer.phones,
                            action: Tappable(
                                on_tap: on_phone_update,
                                child: const Icon(Icons.edit, color: AppColors.neo, size: 16),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: customer!['phones'].map<Widget>((phone) {
                                    return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            const Icon(Icons.phone, size: 18, color: AppColors.neo),
                                            const SizedBox(width: 8),
                                            Text(phone.toString())
                                        ]
                                    );
                                }).toList()
                            )
                        ),
                        const SizedBox(height: 5),
                        InfoTile(
                            title: customer!['tariffs'].length == 1? t.customer.tariff : t.customer.tariffs,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: customer!['tariffs'].map<Widget>((tariff) {
                                    return Text(tariff['content'] ?? t.common.empty, softWrap: true, textAlign: TextAlign.right);
                                }).toList()
                            )
                        ),

                        if (customer!['will_disconnect_at'] != null) ...[
                            const SizedBox(height: 5),
                            InfoTile(
                                title: t.customer.will_disconnect_at,
                                value: format_date(customer!['will_disconnect_at']),
                                preview: true,
                                value_color: get_disconnect_date_color(customer!['will_disconnect_at'])
                            )
                        ],

                        const SizedBox(height: 5),
                        SubHeading(icon: Icons.public, title: t.customer.geodata),
                        if (customer!['address']?['label'] != null)
                        InfoTile(
                            title: t.customer.address,
                            value: customer!['address']!['label'],
                            action: Tooltip(
                                message: t.customer.open_in_2gis,
                                child: Tappable(
                                    on_tap: () => open_url(context, 'https://2gis.kg/osh/search/${customer!['address']['label']}'),
                                    child: const Icon(Icons.open_in_new, size: 18, color: AppColors.neo)
                                )
                            )
                        ),

                        if (customer!['coordinates'] != null) ...[
                            InfoTile(
                                title: t.customer.map_neotelecom,
                                child: Tappable(
                                    on_tap: () => open_url(
                                        context,
                                        '$userside_host/map/show?lat=${customer!['coordinates'][0]}&lon=${customer!['coordinates'][1]}&is_show_center_marker=1@${customer!['coordinates'][0]},${customer!['coordinates'][1]},18z'
                                    ),
                                    child: const Icon(Icons.public, size: 18, color: AppColors.neo)
                                )
                            ),
                            InfoTile(
                                title: t.customer.map_2gis,
                                child: Tappable(
                                    on_tap: () => open_url(context, 'http://2gis.kg/geo/${customer!['coordinates'][0]},${customer!['coordinates'][1]}'),
                                    child: const Icon(Icons.public, size: 18, color: AppColors.neo)
                                )
                            ),
                            InfoTile(title: t.customer.coordinates, value: customer!['coordinates'].join(', '))
                        ],

                        if (customer!['address']?['entrance'] != null)
                        InfoTile(title: t.customer.entrance, value: customer!['address']!['entrance'].toString()),

                        if (customer!['address']?['floor'] != null)
                        InfoTile(title: t.customer.floor, value: customer!['address']!['floor'].toString()),

                        if (customer!['address']?['apartment'] != null)
                        InfoTile(title: t.customer.apartment, value: customer!['address']!['apartment'].toString())
                    ]
                )
        );
    }
}

class _Warning extends StatelessWidget {
    const _Warning({required this.icon, required this.text, required this.color});
    final IconData icon;
    final String text;
    final Color color;

    @override
    Widget build(BuildContext context) {
        return Row(
            spacing: 5,
            children: [
                Icon(icon, color: color, size: 18),
                Flexible(child: Text(text, style: TextStyle(color: color)))
            ]
        );
    }
}
