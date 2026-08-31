---
name: flutter-sliver-animated-list
description: >
  Build a two-section animated list (e.g. To Buy / Completed) using
  SliverAnimatedList inside a CustomScrollView. Items slide and fade smoothly
  between sections when toggled instead of causing a full-list flash rebuild.
  Use when a ListView rebuilds completely on state change and causes a visual
  flash, or whenever you need animated insert/remove in a sectioned list.
tags: [flutter, ui, animation, list, performance]
---

# flutter-sliver-animated-list

## When to Use
- A `ListView` with a flat `children` spread re-renders completely on every
  state update, causing a visual "flash" or scroll-position jump.
- Items need to animate between two sections (e.g. unchecked → checked) with
  a smooth slide + fade instead of an instant re-draw.
- Any sectioned list driven by a `ValueListenable` or stream that diffs
  frequently.

---

## Core Pattern

### 1. Create a `StatefulWidget` that owns two `GlobalKey<SliverAnimatedListState>`

```dart
class AnimatedTwoSectionList extends StatefulWidget {
  final List<MyItem> items;
  // callbacks as functions-returning-callbacks so the list key can reuse builders
  final VoidCallback Function(MyItem) onToggle;
  final VoidCallback Function(MyItem) onDelete;
  final ScrollController scrollController;

  const AnimatedTwoSectionList({super.key, ...});

  @override
  State<AnimatedTwoSectionList> createState() => _AnimatedTwoSectionListState();
}
```

### 2. Maintain previous snapshots of each section

```dart
class _AnimatedTwoSectionListState extends State<AnimatedTwoSectionList> {
  final _topKey  = GlobalKey<SliverAnimatedListState>();
  final _botKey  = GlobalKey<SliverAnimatedListState>();

  late List<MyItem> _prevTop;   // e.g. unchecked items
  late List<MyItem> _prevBot;   // e.g. checked items

  @override
  void initState() {
    super.initState();
    _prevTop = widget.items.where((i) => !i.isDone).toList();
    _prevBot = widget.items.where((i) =>  i.isDone).toList();
  }
```

### 3. Diff on `didUpdateWidget` and drive inserts/removes

```dart
  @override
  void didUpdateWidget(AnimatedTwoSectionList old) {
    super.didUpdateWidget(old);

    final newTop = widget.items.where((i) => !i.isDone).toList();
    final newBot = widget.items.where((i) =>  i.isDone).toList();

    _diff(_topKey, _prevTop, newTop);
    _diff(_botKey, _prevBot, newBot);

    _prevTop = newTop;
    _prevBot = newBot;
  }

  void _diff(
    GlobalKey<SliverAnimatedListState> key,
    List<MyItem> prev,
    List<MyItem> next,
  ) {
    final prevIds = prev.map((i) => i.id).toList();
    final nextIds = next.map((i) => i.id).toList();

    // Remove items that left this section (iterate backwards to keep indices valid)
    for (var i = prevIds.length - 1; i >= 0; i--) {
      if (!nextIds.contains(prevIds[i])) {
        final removed = prev[i];
        key.currentState?.removeItem(
          i,
          (ctx, anim) => _buildTile(ctx, removed, anim),
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    // Insert items that entered this section
    for (var i = 0; i < nextIds.length; i++) {
      if (!prevIds.contains(nextIds[i])) {
        key.currentState?.insertItem(i, duration: const Duration(milliseconds: 300));
      }
    }
  }
```

### 4. Build animated tiles with `SizeTransition` + `FadeTransition`

```dart
  Widget _buildTile(BuildContext ctx, MyItem item, Animation<double> anim) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
      child: FadeTransition(
        opacity: anim,
        child: MyItemTile(
          key: ValueKey('tile_${item.id}'),
          item: item,
          onToggle: widget.onToggle(item),
          onDelete: widget.onDelete(item),
        ),
      ),
    );
  }
```

> **Important:** the `removeItem` callback builder and the `SliverAnimatedList`
> `itemBuilder` must use the same `_buildTile` method so the exit animation
> matches the entry animation exactly.

### 5. Render with `CustomScrollView` + `SliverAnimatedList`

```dart
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: PageStorageKey<String>('list_${someId}'),
      controller: widget.scrollController,
      slivers: [
        // Section A header
        SliverToBoxAdapter(child: _sectionHeader('To Buy', _prevTop.length)),

        SliverAnimatedList(
          key: _topKey,
          initialItemCount: _prevTop.length,
          itemBuilder: (ctx, index, anim) {
            if (index >= _prevTop.length) return const SizedBox.shrink();
            return _buildTile(ctx, _prevTop[index], anim);
          },
        ),

        // Section B header (show only when non-empty)
        if (_prevBot.isNotEmpty)
          SliverToBoxAdapter(child: _sectionHeader('Completed', _prevBot.length)),

        SliverAnimatedList(
          key: _botKey,
          initialItemCount: _prevBot.length,
          itemBuilder: (ctx, index, anim) {
            if (index >= _prevBot.length) return const SizedBox.shrink();
            return _buildTile(ctx, _prevBot[index], anim);
          },
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 8)),
      ],
    );
  }
```

### 6. Wire into the parent view

Replace the plain `ListView` in the parent with:

```dart
AnimatedTwoSectionList(
  key: ValueKey('asl_$listId'),   // stable key prevents full widget recreation
  items: list.items,
  scrollController: _scrollController,
  onToggle: (item) => () => controller.toggleItem(listId, item),
  onDelete: (item) => () => _removeItem(item.id),
)
```

> Use `ValueKey` (not `UniqueKey`) on the widget so Flutter keeps the same
> `State` instance across rebuilds — this is what preserves the diff history.

---

## Key Rules

| Rule | Why |
|---|---|
| Always iterate removals **backwards** | Removing forward shifts indices and causes index-out-of-range crashes |
| Guard `if (index >= list.length)` in `itemBuilder` | The animated list may call the builder with a stale index during transitions |
| Use the **same** builder for `removeItem` and `itemBuilder` | Consistent exit/entry animation |
| Keep `_prev*` as the source of truth inside `build()` | They represent the *currently rendered* state; `widget.items` is the target |
| Use `PageStorageKey` on `CustomScrollView` | Preserves scroll offset across route transitions |

---

## Anti-Patterns to Avoid

- ❌ `ListView(children: [...items.map(...)])` — causes full re-render flash on every state change
- ❌ `UniqueKey()` on the animated list widget — destroys state and loses diff history
- ❌ Calling `insertItem`/`removeItem` outside `didUpdateWidget` (e.g. in a button callback) — bypasses the diff and corrupts index state

---

## Reference Implementation

See [`animated_shopping_list.dart`](file:///c:/Projects/ShoppingExplore/lib/features/shopping_list/presentation/widgets/animated_shopping_list.dart)
for the full working implementation used in ShoppingExplore.
