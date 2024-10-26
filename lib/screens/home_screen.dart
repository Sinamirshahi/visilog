import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../models/store.dart';
import '../utils/excel_helper.dart';
import '../utils/share_helper.dart';
import 'store_form_screen.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _sortBy = 'name'; // 'name', 'date', 'rating'
  bool _sortAscending = true;
  bool _isLoading = false;

  List<Store> _filterAndSortStores(List<Store> stores) {
    // First filter
    var filteredStores = stores.where((store) {
      return store.storeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          store.businessType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          store.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          store.contactPerson.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (store.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();

    // Then sort
    filteredStores.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'name':
          comparison = a.storeName.compareTo(b.storeName);
          break;
        case 'date':
          comparison = a.visitDate.compareTo(b.visitDate);
          break;
        case 'rating':
          comparison = b.partnershipPotential.compareTo(a.partnershipPotential);
          break;
        default:
          comparison = a.storeName.compareTo(b.storeName);
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filteredStores;
  }

  void _showSortingDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sort By'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile(
                  title: const Text('Store Name'),
                  value: 'name',
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value.toString();
                    });
                    this.setState(() {});
                  },
                ),
                RadioListTile(
                  title: const Text('Visit Date'),
                  value: 'date',
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value.toString();
                    });
                    this.setState(() {});
                  },
                ),
                RadioListTile(
                  title: const Text('Partnership Potential'),
                  value: 'rating',
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value.toString();
                    });
                    this.setState(() {});
                  },
                ),
                SwitchListTile(
                  title: const Text('Ascending Order'),
                  value: _sortAscending,
                  onChanged: (value) {
                    setState(() {
                      _sortAscending = value;
                    });
                    this.setState(() {});
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToExcel() async {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final stores = storeProvider.stores;

    if (stores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No stores to export')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final filePath = await ExcelHelper.exportStores(stores);

      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Excel file generated successfully'),
            action: SnackBarAction(
              label: 'SHARE',
              onPressed: () => ShareHelper.shareExcelFile(filePath),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export stores')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  void _deleteStore(BuildContext context, Store store) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Store'),
        content: Text('Are you sure you want to delete ${store.storeName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Provider.of<StoreProvider>(context, listen: false)
                  .deleteStore(store.id!);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${store.storeName} has been deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      Provider.of<StoreProvider>(context, listen: false)
                          .addStore(store);
                    },
                  ),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(Store store, BuildContext context) {
    return Dismissible(
      key: Key(store.id ?? ''),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Store'),
            content: Text('Are you sure you want to delete ${store.storeName}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<StoreProvider>(context, listen: false).deleteStore(store.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${store.storeName} has been deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                Provider.of<StoreProvider>(context, listen: false).addStore(store);
              },
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoreFormScreen(store: store),
              ),
            );
          },
          child: Column(
            children: [
              ListTile(
                leading: Hero(
                  tag: 'store_image_${store.id}',
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: store.photoPath != null
                        ? FileImage(File(store.photoPath!))
                        : null,
                    child: store.photoPath == null
                        ? const Icon(Icons.store)
                        : null,
                  ),
                ),
                title: Text(
                  store.storeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(store.businessType),
                    Text(
                      store.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: const [
                          Icon(Icons.share, size: 20),
                          SizedBox(width: 8),
                          Text('Share'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoreFormScreen(store: store),
                          ),
                        );
                        break;
                      case 'share':
                        ShareHelper.shareStoreDetails(store);
                        break;
                      case 'delete':
                        _deleteStore(context, store);
                        break;
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visited: ${DateFormat('MMM dd, yyyy').format(store.visitDate)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (store.followUpDate != null)
                          Text(
                            'Follow-up: ${DateFormat('MMM dd, yyyy').format(store.followUpDate!)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: store.isFollowUpDue
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: List.generate(
                        5,
                            (index) => Icon(
                          Icons.star,
                          size: 16,
                          color: index < store.partnershipPotential
                              ? Colors.amber
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Visits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortingDialog,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _isLoading ? null : _exportToExcel,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search stores...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Consumer<StoreProvider>(
              builder: (context, storeProvider, child) {
                final filteredStores = _filterAndSortStores(storeProvider.stores);

                if (storeProvider.stores.isEmpty) {
                  return const Center(
                    child: Text('No stores visited yet. Tap + to add one.'),
                  );
                }

                if (filteredStores.isEmpty) {
                  return const Center(
                    child: Text('No stores match your search.'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredStores.length,
                  itemBuilder: (context, index) {
                    return _buildStoreCard(filteredStores[index], context);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StoreFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}