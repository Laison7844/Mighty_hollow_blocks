import 'package:flutter/material.dart';
import 'package:flutter_projects/model/customer_model.dart';
import 'package:flutter_projects/repository/customer_repository.dart';
import 'package:flutter_projects/ui/customs/textfield_custom.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddCustomer extends ConsumerStatefulWidget {
  const AddCustomer({super.key});
  static String path = "/add-customer";

  @override
  ConsumerState<AddCustomer> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends ConsumerState<AddCustomer> {
  // Controllers for the form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController salesController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    salesController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and Phone are required")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final newCustomer = CustomerModel(
      companyName: nameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      address: addressController.text.trim(),
      description: descriptionController.text.trim(),
      totalSales:
          int.tryParse(salesController.text.replaceAll(',', '').trim()) ?? 0,
      registrationDate: DateTime.now(),
    );

    try {
      await ref.read(customerRepositoryProvider).addCustomer(newCustomer);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Customer Added Successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error adding customer: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Register New Customer",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Customer Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Add the customer identity, contact details and optional notes in one place.",
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: "Basic information",
              icon: Icons.badge_outlined,
              children: [
                _buildLabel("Company Name / Customer Name"),
                TextfieldCustom(hintText: "Name", controller: nameController),
                const SizedBox(height: 16),
                _buildLabel("Phone Number"),
                TextfieldCustom(
                  hintText: "Phone Number",
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  suffix: const Icon(Icons.phone_outlined, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: "Address and notes",
              icon: Icons.location_on_outlined,
              children: [
                _buildLabel("Customer Address"),
                TextfieldCustom(
                  hintText: "Full address",
                  controller: addressController,
                  suffix: const Icon(Icons.location_on_outlined, size: 20),
                  maxLines: 3,
                  minLines: 2,
                ),
                const SizedBox(height: 16),
                _buildLabel("Description"),
                TextfieldCustom(
                  hintText: "Add customer notes, site details or reminders",
                  controller: descriptionController,
                  maxLines: 4,
                  minLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: "Commercial summary",
              icon: Icons.payments_outlined,
              children: [
                _buildLabel("Initial Lifetime Sales"),
                TextfieldCustom(
                  hintText: "50,000",
                  controller: salesController,
                  keyboardType: TextInputType.number,
                  suffix: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      "₹",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveCustomer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Register Customer",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}
