import 'package:flutter/material.dart';
import 'package:promitheas/features/auth/widgets/decoration.dart';

class SignupForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmCtrl;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController phoneCtrl;
  final DateTime? birthday;
  final VoidCallback onPickBirthday;

  const SignupForm({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.phoneCtrl,
    required this.birthday,
    required this.onPickBirthday,
  });

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: CustomInputDeco.get(context, 'Email', Icons.email_outlined),
            validator: (v) => (v == null || v.isEmpty) ? 'Enter your email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.passCtrl,
            obscureText: _obscurePass,
            textInputAction: TextInputAction.next,
            decoration: CustomInputDeco.get(context, 'Password', Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
            validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.confirmCtrl,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.next,
            decoration: CustomInputDeco.get(context, 'Confirm password', Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirm your password';
              if (v != widget.passCtrl.text) return 'The passwords dont match';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: widget.firstNameCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: CustomInputDeco.get(context, 'Name', Icons.person_outline),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: widget.lastNameCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: CustomInputDeco.get(context, 'Surname', Icons.person_outline),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.phoneCtrl,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: CustomInputDeco.get(context, 'Phone (optional)', Icons.phone_outlined),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: widget.onPickBirthday,
            child: AbsorbPointer(
              child: TextFormField(
                readOnly: true,
                decoration: CustomInputDeco.get(
                  context,
                  widget.birthday == null
                      ? 'Date of birth (optional)'
                      : '${widget.birthday!.day.toString().padLeft(2, '0')}/${widget.birthday!.month.toString().padLeft(2, '0')}/${widget.birthday!.year}',
                  Icons.cake_outlined,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
