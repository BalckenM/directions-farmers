import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';

// ── In-memory stock item model ────────────────────────────────────────────────

class _StockItem {
  _StockItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minStock,
  });

  final String id;
  final String name;

  /// 'medicine' | 'supplement'
  final String category;
  double quantity;
  final String unit;
  final double minStock;

  bool get isLow => quantity <= minStock;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class CattleInventoryScreen extends ConsumerStatefulWidget {
  const CattleInventoryScreen({super.key});

  @override
  ConsumerState<CattleInventoryScreen> createState() =>
      _CattleInventoryScreenState();
}

class _CattleInventoryScreenState extends ConsumerState<CattleInventoryScreen> {
  final List<_StockItem> _items = [
    // Medicines
    _StockItem(
      id: 'm1',
      name: 'Terramycin LA',
      category: 'medicine',
      quantity: 250,
      unit: 'mL',
      minStock: 100,
    ),
    _StockItem(
      id: 'm2',
      name: 'Ivomec (Ivermectin)',
      category: 'medicine',
      quantity: 50,
      unit: 'mL',
      minStock: 100,
    ),
    _StockItem(
      id: 'm3',
      name: 'Lumpy Skin Vaccine',
      category: 'medicine',
      quantity: 20,
      unit: 'doses',
      minStock: 30,
    ),
    _StockItem(
      id: 'm4',
      name: 'Anthrax Vaccine',
      category: 'medicine',
      quantity: 40,
      unit: 'doses',
      minStock: 20,
    ),
    _StockItem(
      id: 'm5',
      name: 'Dip Solution (Triatix)',
      category: 'medicine',
      quantity: 5,
      unit: 'L',
      minStock: 10,
    ),
    // Supplements
    _StockItem(
      id: 's1',
      name: 'Protein Lick',
      category: 'supplement',
      quantity: 200,
      unit: 'kg',
      minStock: 50,
    ),
    _StockItem(
      id: 's2',
      name: 'Mineral Lick',
      category: 'supplement',
      quantity: 35,
      unit: 'kg',
      minStock: 50,
    ),
    _StockItem(
      id: 's3',
      name: 'Maize Meal',
      category: 'supplement',
      quantity: 500,
      unit: 'kg',
      minStock: 100,
    ),
    _StockItem(
      id: 's4',
      name: 'Silage',
      category: 'supplement',
      quantity: 800,
      unit: 'kg',
      minStock: 200,
    ),
  ];

  int _currentTab = 0;

  void _showAddDialog(String category) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final unitCtrl = TextEditingController(
      text: category == 'medicine' ? 'mL' : 'kg',
    );
    final minCtrl = TextEditingController(text: '10');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Add ${category == 'medicine' ? 'Medicine' : 'Supplement'}',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name *'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: qtyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Quantity *',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: unitCtrl,
                      decoration: const InputDecoration(labelText: 'Unit'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: minCtrl,
                decoration: const InputDecoration(
                  labelText: 'Low stock threshold',
                  helperText: 'Alert when quantity drops below this',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final qty = double.tryParse(qtyCtrl.text.trim());
              if (name.isEmpty || qty == null) return;
              setState(() {
                _items.add(
                  _StockItem(
                    id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    category: category,
                    quantity: qty,
                    unit: unitCtrl.text.trim().isEmpty
                        ? 'units'
                        : unitCtrl.text.trim(),
                    minStock: double.tryParse(minCtrl.text.trim()) ?? 10,
                  ),
                );
              });
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medicines = _items.where((i) => i.category == 'medicine').toList();
    final supplements = _items
        .where((i) => i.category == 'supplement')
        .toList();
    final lowCount = _items.where((i) => i.isLow).length;
    final currentCategory = _currentTab == 0 ? 'medicine' : 'supplement';

    return DefaultTabController(
      length: 2,
      child: FarmScaffold(
        appBar: FarmAppBar(
          title: 'Medicine & Supplement Stock',
          subtitle: lowCount > 0
              ? '$lowCount item(s) below minimum'
              : 'All levels OK',
          bottom: TabBar(
            onTap: (i) => setState(() => _currentTab = i),
            tabs: [
              Tab(text: 'Medicines (${medicines.length})'),
              Tab(text: 'Supplements (${supplements.length})'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'inv_add',
          onPressed: () => _showAddDialog(currentCategory),
          child: const Icon(Icons.add_rounded),
        ),
        body: Column(
          children: [
            if (lowCount > 0)
              Material(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Theme.of(context).colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$lowCount item${lowCount == 1 ? '' : 's'} below '
                          'minimum stock level — reorder needed',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  _StockList(
                    items: medicines,
                    emptyIcon: Icons.medication_outlined,
                    emptyLabel: 'No medicines recorded',
                    onAdd: () => _showAddDialog('medicine'),
                  ),
                  _StockList(
                    items: supplements,
                    emptyIcon: Icons.grass_outlined,
                    emptyLabel: 'No supplements recorded',
                    onAdd: () => _showAddDialog('supplement'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stock list ────────────────────────────────────────────────────────────────

class _StockList extends StatelessWidget {
  const _StockList({
    required this.items,
    required this.emptyIcon,
    required this.emptyLabel,
    required this.onAdd,
  });

  final List<_StockItem> items;
  final IconData emptyIcon;
  final String emptyLabel;
  final VoidCallback onAdd;

  String _fmt(double qty) {
    if (qty == qty.roundToDouble()) return qty.toStringAsFixed(0);
    return qty.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 52, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(emptyLabel, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Item'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final item = items[i];
        final isLow = item.isLow;
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: isLow
              ? Theme.of(ctx).colorScheme.errorContainer.withAlpha(60)
              : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isLow
                  ? Theme.of(ctx).colorScheme.error
                  : Theme.of(ctx).colorScheme.primaryContainer,
              child: Icon(
                item.category == 'medicine'
                    ? Icons.medication_rounded
                    : Icons.grass_rounded,
                size: 20,
                color: isLow
                    ? Colors.white
                    : Theme.of(ctx).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Row(
              children: [
                Expanded(child: Text(item.name)),
                if (isLow)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.error,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text('Min: ${_fmt(item.minStock)} ${item.unit}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_fmt(item.quantity)} ${item.unit}',
                  style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isLow
                        ? Theme.of(ctx).colorScheme.error
                        : Theme.of(ctx).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
