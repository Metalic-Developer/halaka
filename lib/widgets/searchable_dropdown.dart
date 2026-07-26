import 'package:flutter/material.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?>? onChanged;
  final T? initialValue;
  final String? hint;

  const SearchableDropdown({
    super.key,
    required this.items,
    required this.labelBuilder,
    this.onChanged,
    this.initialValue,
    this.hint,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _searchCtrl = TextEditingController();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  List<T> filtered = [];

  @override
  void initState() {
    super.initState();
    filtered = widget.items;
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 48),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (ctx, i) => ListTile(
                  title: Text(widget.labelBuilder(filtered[i])),
                  onTap: () {
                    widget.onChanged?.call(filtered[i]);
                    _searchCtrl.text = widget.labelBuilder(filtered[i]);
                    _removeOverlay();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: widget.hint ?? 'بحث...',
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        onTap: () {
          _showOverlay();
        },
        onChanged: (val) {
          setState(() {
            filtered = widget.items.where((item) => widget.labelBuilder(item).contains(val)).toList();
          });
          _overlayEntry?.markNeedsBuild();
        },
      ),
    );
  }
}