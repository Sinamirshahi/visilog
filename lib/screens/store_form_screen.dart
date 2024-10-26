// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:io';
// import 'package:intl/intl.dart';
// import '../models/store.dart';
// import '../providers/store_provider.dart';
// import '../utils/image_helper.dart';
// import '../utils/location_helper.dart';
// import 'package:geolocator/geolocator.dart';
//
// class StoreFormScreen extends StatefulWidget {
//   final Store? store;
//
//   const StoreFormScreen({Key? key, this.store}) : super(key: key);
//
//   @override
//   _StoreFormScreenState createState() => _StoreFormScreenState();
// }
//
// class _StoreFormScreenState extends State<StoreFormScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String? _photoPath;
//   Position? _currentPosition;
//   bool _isLoading = false;
//
//   // Form controllers
//   final TextEditingController _storeNameController = TextEditingController();
//   final TextEditingController _businessTypeController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _contactPersonController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _businessHoursController = TextEditingController();
//   final TextEditingController _websiteController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();
//   DateTime _visitDate = DateTime.now();
//   DateTime? _followUpDate;
//   int _partnershipPotential = 3;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     setState(() => _isLoading = true);
//
//     // Load existing store data if editing
//     if (widget.store != null) {
//       _loadStoreData();
//     }
//
//     // Get current location
//     try {
//       final position = await LocationHelper.getCurrentLocation();
//       if (position != null) {
//         setState(() => _currentPosition = position);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not get location: $e')),
//       );
//     }
//
//     setState(() => _isLoading = false);
//   }
//
//   void _loadStoreData() {
//     final store = widget.store!;
//     _storeNameController.text = store.storeName;
//     _businessTypeController.text = store.businessType;
//     _addressController.text = store.address;
//     _contactPersonController.text = store.contactPerson;
//     _phoneController.text = store.phoneNumber;
//     _emailController.text = store.email ?? '';
//     _businessHoursController.text = store.businessHours;
//     _websiteController.text = store.website ?? '';
//     _notesController.text = store.notes ?? '';
//     _photoPath = store.photoPath;
//     _visitDate = store.visitDate;
//     _followUpDate = store.followUpDate;
//     _partnershipPotential = store.partnershipPotential;
//   }
//
//   Future<void> _handleImageSelection() async {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Take Photo'),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   final imagePath = await ImageHelper.takePhoto();
//                   if (imagePath != null) {
//                     setState(() => _photoPath = imagePath);
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Choose from Gallery'),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   final imagePath = await ImageHelper.pickImage();
//                   if (imagePath != null) {
//                     setState(() => _photoPath = imagePath);
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _handleDatePicker(bool isFollowUp) async {
//     final DateTime currentDate = isFollowUp ? (_followUpDate ?? DateTime.now()) : _visitDate;
//     final DateTime firstDate = isFollowUp ? DateTime.now() : DateTime(2020);
//     final DateTime lastDate = DateTime(2025);
//
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: currentDate,
//       firstDate: firstDate,
//       lastDate: lastDate,
//     );
//
//     if (picked != null) {
//       setState(() {
//         if (isFollowUp) {
//           _followUpDate = picked;
//         } else {
//           _visitDate = picked;
//         }
//       });
//     }
//   }
//
//   bool _validateForm() {
//     if (!_formKey.currentState!.validate()) return false;
//     if (_currentPosition == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please wait for location data')),
//       );
//       return false;
//     }
//     return true;
//   }
//
//   Future<void> _saveStore() async {
//     if (!_validateForm()) return;
//
//     try {
//       setState(() => _isLoading = true);
//
//       final store = Store(
//         id: widget.store?.id,
//         storeName: _storeNameController.text.trim(),
//         businessType: _businessTypeController.text.trim(),
//         photoPath: _photoPath,
//         latitude: _currentPosition?.latitude ?? 0.0,
//         longitude: _currentPosition?.longitude ?? 0.0,
//         address: _addressController.text.trim(),
//         contactPerson: _contactPersonController.text.trim(),
//         phoneNumber: _phoneController.text.trim(),
//         email: _emailController.text.trim(),
//         visitDate: _visitDate,
//         businessHours: _businessHoursController.text.trim(),
//         website: _websiteController.text.trim(),
//         notes: _notesController.text.trim(),
//         followUpDate: _followUpDate,
//         partnershipPotential: _partnershipPotential,
//       );
//
//       final storeProvider = Provider.of<StoreProvider>(context, listen: false);
//       if (widget.store == null) {
//         storeProvider.addStore(store);
//       } else {
//         storeProvider.updateStore(store);
//       }
//
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving store: $e')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.store == null ? 'Add Store' : 'Edit Store'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: _isLoading ? null : _saveStore,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Photo Section
//               Center(
//                 child: GestureDetector(
//                   onTap: _handleImageSelection,
//                   child: Container(
//                     width: 150,
//                     height: 150,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: _photoPath != null
//                         ? ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Image.file(
//                         File(_photoPath!),
//                         fit: BoxFit.cover,
//                       ),
//                     )
//                         : const Icon(
//                       Icons.add_a_photo,
//                       size: 50,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Form Fields
//               TextFormField(
//                 controller: _storeNameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Store Name*',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter store name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               TextFormField(
//                 controller: _businessTypeController,
//                 decoration: const InputDecoration(
//                   labelText: 'Business Type*',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter business type';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               TextFormField(
//                 controller: _addressController,
//                 decoration: const InputDecoration(
//                   labelText: 'Address*',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 2,
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter address';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               TextFormField(
//                 controller: _contactPersonController,
//                 decoration: const InputDecoration(
//                   labelText: 'Contact Person*',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter contact person name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: const InputDecoration(
//                   labelText: 'Phone Number*',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.phone,
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter phone number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Email Address',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 16),
//
//               TextFormField(
//                 controller: _businessHoursController,
//                 decoration: const InputDecoration(
//                   labelText: 'Business Hours*',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter business hours';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               TextFormField(
//                 controller: _websiteController,
//                 decoration: const InputDecoration(
//                   labelText: 'Website',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.url,
//               ),
//               const SizedBox(height: 16),
//
//               // Partnership Potential
//               Text('Partnership Potential: $_partnershipPotential',
//                   style: Theme.of(context).textTheme.titleMedium),
//               Slider(
//                 value: _partnershipPotential.toDouble(),
//                 min: 1,
//                 max: 5,
//                 divisions: 4,
//                 label: _partnershipPotential.toString(),
//                 onChanged: (double value) {
//                   setState(() {
//                     _partnershipPotential = value.round();
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//
//               TextFormField(
//                 controller: _notesController,
//                 decoration: const InputDecoration(
//                   labelText: 'Notes',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 16),
//
//               // Date Selection
//               ListTile(
//                 title: const Text('Visit Date'),
//                 subtitle: Text(
//                   DateFormat('yyyy-MM-dd').format(_visitDate),
//                 ),
//                 trailing: const Icon(Icons.calendar_today),
//                 onTap: () => _handleDatePicker(false),
//               ),
//
//               ListTile(
//                 title: const Text('Follow-up Date'),
//                 subtitle: Text(
//                   _followUpDate != null
//                       ? DateFormat('yyyy-MM-dd').format(_followUpDate!)
//                       : 'Not set',
//                 ),
//                 trailing: const Icon(Icons.calendar_today),
//                 onTap: () => _handleDatePicker(true),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _storeNameController.dispose();
//     _businessTypeController.dispose();
//     _addressController.dispose();
//     _contactPersonController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _businessHoursController.dispose();
//     _websiteController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../models/store.dart';
import '../providers/store_provider.dart';
import '../utils/image_helper.dart';
import '../utils/location_helper.dart';
import 'package:geolocator/geolocator.dart';

class StoreFormScreen extends StatefulWidget {
  final Store? store;

  const StoreFormScreen({Key? key, this.store}) : super(key: key);

  @override
  _StoreFormScreenState createState() => _StoreFormScreenState();
}

class _StoreFormScreenState extends State<StoreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _photoPath;
  Position? _currentPosition;
  bool _isLoading = false;

  // Form controllers
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _businessTypeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _businessHoursController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _visitDate = DateTime.now();
  DateTime? _followUpDate;
  int _partnershipPotential = 3;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load existing store data if editing
    if (widget.store != null) {
      _loadStoreData();
    }

    // Get current location
    try {
      final position = await LocationHelper.getCurrentLocation();
      if (position != null) {
        setState(() => _currentPosition = position);
      } else {
        // Set current position to null if location is unavailable
        setState(() => _currentPosition = null);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get location: $e')),
      );
      setState(() => _currentPosition = null);  // Proceed without location
    }

    setState(() => _isLoading = false);
  }

  void _loadStoreData() {
    final store = widget.store!;
    _storeNameController.text = store.storeName;
    _businessTypeController.text = store.businessType;
    _addressController.text = store.address;
    _contactPersonController.text = store.contactPerson;
    _phoneController.text = store.phoneNumber;
    _emailController.text = store.email ?? '';
    _businessHoursController.text = store.businessHours;
    _websiteController.text = store.website ?? '';
    _notesController.text = store.notes ?? '';
    _photoPath = store.photoPath;
    _visitDate = store.visitDate;
    _followUpDate = store.followUpDate;
    _partnershipPotential = store.partnershipPotential;
  }

  Future<void> _handleImageSelection() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePath = await ImageHelper.takePhoto();
                  if (imagePath != null) {
                    setState(() => _photoPath = imagePath);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePath = await ImageHelper.pickImage();
                  if (imagePath != null) {
                    setState(() => _photoPath = imagePath);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleDatePicker(bool isFollowUp) async {
    final DateTime currentDate = isFollowUp ? (_followUpDate ?? DateTime.now()) : _visitDate;
    final DateTime firstDate = isFollowUp ? DateTime.now() : DateTime(2020);
    final DateTime lastDate = DateTime(2025);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isFollowUp) {
          _followUpDate = picked;
        } else {
          _visitDate = picked;
        }
      });
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;
    // No need to check for location availability anymore
    return true;
  }

  Future<void> _saveStore() async {
    if (!_validateForm()) return;

    try {
      setState(() => _isLoading = true);

      final store = Store(
        id: widget.store?.id,
        storeName: _storeNameController.text.trim(),
        businessType: _businessTypeController.text.trim(),
        photoPath: _photoPath,
        latitude: _currentPosition?.latitude ?? 0.0,  // Or save as null based on your model
        longitude: _currentPosition?.longitude ?? 0.0,  // Or save as null based on your model
        address: _addressController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        visitDate: _visitDate,
        businessHours: _businessHoursController.text.trim(),
        website: _websiteController.text.trim(),
        notes: _notesController.text.trim(),
        followUpDate: _followUpDate,
        partnershipPotential: _partnershipPotential,
      );

      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      if (widget.store == null) {
        storeProvider.addStore(store);
      } else {
        storeProvider.updateStore(store);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving store: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.store == null ? 'Add Store' : 'Edit Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveStore,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Section
              Center(
                child: GestureDetector(
                  onTap: _handleImageSelection,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _photoPath != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(_photoPath!),
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Icon(
                      Icons.add_a_photo,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Form Fields
              TextFormField(
                controller: _storeNameController,
                decoration: const InputDecoration(
                  labelText: 'Store Name*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter store name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _businessTypeController,
                decoration: const InputDecoration(
                  labelText: 'Business Type*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter business type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address*',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contactPersonController,
                decoration: const InputDecoration(
                  labelText: 'Contact Person*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter contact person name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number*',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _businessHoursController,
                decoration: const InputDecoration(
                  labelText: 'Business Hours*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter business hours';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              // Partnership Potential
              Text('Partnership Potential: $_partnershipPotential',
                  style: Theme.of(context).textTheme.titleMedium),
              Slider(
                value: _partnershipPotential.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _partnershipPotential.toString(),
                onChanged: (double value) {
                  setState(() {
                    _partnershipPotential = value.round();
                  });
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Date Selection
              ListTile(
                title: const Text('Visit Date'),
                subtitle: Text(
                  DateFormat('yyyy-MM-dd').format(_visitDate),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _handleDatePicker(false),
              ),

              ListTile(
                title: const Text('Follow-up Date'),
                subtitle: Text(
                  _followUpDate != null
                      ? DateFormat('yyyy-MM-dd').format(_followUpDate!)
                      : 'Not set',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _handleDatePicker(true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _businessTypeController.dispose();
    _addressController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _businessHoursController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

