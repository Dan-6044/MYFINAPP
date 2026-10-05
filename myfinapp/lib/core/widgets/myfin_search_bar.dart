import 'package:flutter/material.dart';

class MyfinSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const MyfinSearchBar({
    super.key,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<MyfinSearchBar> createState() => _MyfinSearchBarState();
}

class _MyfinSearchBarState extends State<MyfinSearchBar> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: Color(0xFF000000)),
      decoration: InputDecoration(
        hintText: 'Search modules...',
        hintStyle: const TextStyle(color: Color(0xFF5F6B76)),
        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF7A8A9A)),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF7A8A9A)),
                onPressed: () {
                  _controller.clear();
                  widget.onClear();
                },
              ),
        filled: true,
        fillColor: const Color(0xFFF5F8FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD6E2F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD6E2F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD6E2F0)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
