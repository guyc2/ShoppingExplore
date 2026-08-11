import 'package:flutter/material.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import '../../domain/entities/shopping_item.dart';
import 'shopping_item_tile.dart';

/// Duration for item slide animations.
const Duration _kAnimDuration = Duration(milliseconds: 300);

/// A two-section animated list (To Buy / Completed) that slides items
/// smoothly between sections when toggled, without any full-page flash.
///
/// Uses [SliverAnimatedList] internally so inserts and removes are driven
/// by explicit diff comparisons against the previous item snapshot.
class AnimatedShoppingList extends StatefulWidget {
  final List<ShoppingItem> items;
  final String listId;
  final VoidCallback Function(ShoppingItem) onToggle;
  final VoidCallback Function(ShoppingItem) onDelete;
  final VoidCallback Function(ShoppingItem) onTap;
  final void Function(ShoppingItem, double) onUpdateQuantity;
  final ScrollController scrollController;

  const AnimatedShoppingList({
    super.key,
    required this.items,
    required this.listId,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
    required this.onUpdateQuantity,
    required this.scrollController,
  });

  @override
  State<AnimatedShoppingList> createState() => _AnimatedShoppingListState();
}

class _AnimatedShoppingListState extends State<AnimatedShoppingList> {
  final _toDoKey = GlobalKey<SliverAnimatedListState>();
  final _doneKey = GlobalKey<SliverAnimatedListState>();

  late List<ShoppingItem> _prevTodo;
  late List<ShoppingItem> _prevDone;

  @override
  void initState() {
    super.initState();
    _prevTodo = widget.items.where((i) => !i.isCompleted).toList();
    _prevDone = widget.items.where((i) => i.isCompleted).toList();
  }

  @override
  void didUpdateWidget(AnimatedShoppingList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newTodo = widget.items.where((i) => !i.isCompleted).toList();
    final newDone = widget.items.where((i) => i.isCompleted).toList();

    _diffAndAnimate(_toDoKey, _prevTodo, newTodo, completed: false);
    _diffAndAnimate(_doneKey, _prevDone, newDone, completed: true);

    _prevTodo = newTodo;
    _prevDone = newDone;
  }

  /// Diffs [prev] against [next] and drives [SliverAnimatedListState] inserts/removes.
  void _diffAndAnimate(
    GlobalKey<SliverAnimatedListState> key,
    List<ShoppingItem> prev,
    List<ShoppingItem> next, {
    required bool completed,
  }) {
    final prevIds = prev.map((i) => i.id).toList();
    final nextIds = next.map((i) => i.id).toList();

    // Find removed items (in prev but not in next)
    for (var i = prevIds.length - 1; i >= 0; i--) {
      if (!nextIds.contains(prevIds[i])) {
        final removedItem = prev[i];
        key.currentState?.removeItem(
          i,
          (context, animation) =>
              _buildTile(context, removedItem, animation, completed: completed),
          duration: _kAnimDuration,
        );
      }
    }

    // Find inserted items (in next but not in prev)
    for (var i = 0; i < nextIds.length; i++) {
      if (!prevIds.contains(nextIds[i])) {
        key.currentState?.insertItem(i, duration: _kAnimDuration);
      }
    }
  }

  Widget _buildTile(
    BuildContext context,
    ShoppingItem item,
    Animation<double> animation, {
    required bool completed,
  }) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: FadeTransition(
        opacity: animation,
        child: ShoppingItemTile(
          key: ValueKey('tile_${item.id}_$completed'),
          item: item,
          onToggle: widget.onToggle(item),
          onDelete: widget.onDelete(item),
          onTap: widget.onTap(item),
          onUpdateQuantity: (qty) => widget.onUpdateQuantity(item, qty),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final todoList = _prevTodo;
    final doneList = _prevDone;

    return CustomScrollView(
      key: PageStorageKey<String>('animated_list_${widget.listId}'),
      controller: widget.scrollController,
      slivers: [
        // ── To Buy header ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              '${l10n?.toBuySection ?? 'To Buy'} (${todoList.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),

        // ── To Buy animated section ───────────────────────────────────────
        SliverAnimatedList(
          key: _toDoKey,
          initialItemCount: todoList.length,
          itemBuilder: (context, index, animation) {
            if (index >= todoList.length) return const SizedBox.shrink();
            return _buildTile(context, todoList[index], animation, completed: false);
          },
        ),

        // ── Completed header (only when there are done items) ─────────────
        if (doneList.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 16, bottom: 8),
              child: Text(
                '${l10n?.completedSection ?? 'Completed'} (${doneList.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ),

        // ── Completed animated section ────────────────────────────────────
        SliverAnimatedList(
          key: _doneKey,
          initialItemCount: doneList.length,
          itemBuilder: (context, index, animation) {
            if (index >= doneList.length) return const SizedBox.shrink();
            return _buildTile(context, doneList[index], animation, completed: true);
          },
        ),

        // Bottom padding so last item isn't obscured by the add-bar
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
      ],
    );
  }
}
