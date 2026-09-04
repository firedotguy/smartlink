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
        super.key
    });
    final Map? customer;
    final Map? building;

    final VoidCallback on_refresh;
    final VoidCallback on_open_ont;
    final VoidCallback on_new_task;

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
                    on_pressed: null // TODO: вернуть диалог вложений
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
                        ..._warnings(),
                        ..._main_info(),
                        const SizedBox(height: 5),
                        ..._phones_and_tariffs(),

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
                        ..._geodata(context)
                    ]
                )
        );
    }

    List<Widget> _warnings() {
        final String? last_active = customer!['last_active_at'];

        return [
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

            if (last_active != null && get_activity_color(last_active) == AppColors.error)
            _Warning(
                icon: Icons.access_time,
                text: t.customer.last_activity_warning(
                    FlutterDateFormatter.formatRelativeDateTime(parse_api_date(last_active)!)
                ),
                color: AppColors.error
            ),

            if (get_building_border_color(building?['customers']) == AppColors.error)
            _Warning(icon: Icons.build_circle_outlined, text: t.customer.building_problems, color: AppColors.error)
        ];
    }

    List<Widget> _main_info() {
        return [
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
            )
        ];
    }

    List<Widget> _phones_and_tariffs() {
        final List phones = customer!['phones'] ?? const [];
        final List tariffs = customer!['tariffs'] ?? const [];

        return [
            InfoTile(
                title: phones.length == 1? t.customer.phone : t.customer.phones,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: phones.map<Widget>((phone) {
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
                title: tariffs.length == 1? t.customer.tariff : t.customer.tariffs,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: tariffs.map<Widget>((tariff) {
                        return Text(tariff['content'] ?? t.common.empty, softWrap: true, textAlign: TextAlign.right);
                    }).toList()
                )
            )
        ];
    }

    List<Widget> _geodata(BuildContext context) {
        final Map? address = customer!['address'];
        final List? coordinates = customer!['coordinates'];

        return [
            if (address?['label'] != null)
            InfoTile(
                title: t.customer.address,
                value: address!['label'],
                action: Tooltip(
                    message: t.customer.open_in_2gis,
                    child: Tappable(
                        on_tap: () => open_url(context, 'https://2gis.kg/osh/search/${address['label']}'),
                        child: const Icon(Icons.open_in_new, size: 18, color: AppColors.neo)
                    )
                )
            ),

            if (coordinates != null) ...[
                InfoTile(
                    title: t.customer.map_neotelecom,
                    child: Tappable(
                        on_tap: () => open_url(
                            context,
                            '$userside_host/map/show?lat=${coordinates[0]}&lon=${coordinates[1]}&is_show_center_marker=1@${coordinates[0]},${coordinates[1]},18z'
                        ),
                        child: const Icon(Icons.public, size: 18, color: AppColors.neo)
                    )
                ),
                InfoTile(
                    title: t.customer.map_2gis,
                    child: Tappable(
                        on_tap: () => open_url(context, 'http://2gis.kg/geo/${coordinates[0]},${coordinates[1]}'),
                        child: const Icon(Icons.public, size: 18, color: AppColors.neo)
                    )
                ),
                InfoTile(title: t.customer.coordinates, value: coordinates.join(', '))
            ],

            if (address?['entrance'] != null)
            InfoTile(title: t.customer.entrance, value: address!['entrance'].toString()),

            if (address?['floor'] != null)
            InfoTile(title: t.customer.floor, value: address!['floor'].toString()),

            if (address?['apartment'] != null)
            InfoTile(title: t.customer.apartment, value: address!['apartment'].toString())
        ];
    }
}

/// Строка-предупреждение в шапке карточки абонента.
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
