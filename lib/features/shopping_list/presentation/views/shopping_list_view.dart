import 'package:flutter/material.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import '../../../../core/utils/logger.dart';
import 'package:shopping_explore/features/auth/presentation/controllers/auth_controller.dart';
import 'package:shopping_explore/features/auth/presentation/widgets/auth_user_button.dart';
import 'package:shopping_explore/features/auth/presentation/views/account_profile_modal.dart';
import 'package:shopping_explore/features/auth/presentation/views/login_view.dart';
import '../../domain/entities/shopping_list.dart';
import '../controllers/shopping_list_controller.dart';
import '../controllers/shopping_list_state.dart';
import '../widgets/shopping_list_card.dart';
import '../widgets/create_shopping_list_modal.dart';
import 'shopping_list_detail_view.dart';
import '../../../../core/services/image_storage_service.dart';

/// The main home page — a stylish multi-list dashboard displaying all
/// the user's shopping lists in a responsive grid. Includes a greeting
/// banner, shopping cart brand icon, account menu, and a FAB for
/// creating new lists.
class ShoppingListView extends StatefulWidget {
  final ShoppingListController controller;
  final AuthController? authController;
  final ThemeMode? themeMode;
  final VoidCallback? onToggleTheme;
  final Locale? currentLocale;
  final VoidCallback? onToggleLocale;
  final ImageStorageService imageStorageService;

  const ShoppingListView({
    super.key,
    required this.controller,
    this.authController,
    this.themeMode,
    this.onToggleTheme,
    this.currentLocale,
    this.onToggleLocale,
    required this.imageStorageService,
  });

  @override
  State<ShoppingListView> createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView> {
  @override
  void initState() {
    super.initState();
    AppLogger.i('Initializing ShoppingListView...', tag: 'ShoppingListView');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadShoppingLists();
      widget.authController?.checkAuthStatus();
    });
  }

  void _openListDetail(BuildContext context, ShoppingList list) {
    AppLogger.d('Navigating to list detail: ${list.id}',
        tag: 'ShoppingListView');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ShoppingListDetailView(
          controller: widget.controller,
          listId: list.id,
          imageStorageService: widget.imageStorageService,
        ),
      ),
    );
  }

  void _openCreateListModal(BuildContext context) {
    AppLogger.d('Opening create list modal', tag: 'ShoppingListView');
    showDialog<void>(
      context: context,
      builder: (_) => CreateShoppingListModal(
        onCreate: (title, shortDesc, colorHex, imageUrl) async {
          final newList = await widget.controller.createList(
            title: title,
            shortDescription: shortDesc,
            colorHex: colorHex,
            imageUrl: imageUrl,
            ownerId: _getCurrentUserEmail(),
          );
          if (newList != null && context.mounted) {
            _openListDetail(context, newList);
          }
        },
      ),
    );
  }

  void _openAccountProfile(BuildContext context, List<ShoppingList> lists) {
    AppLogger.d('Opening account profile modal', tag: 'ShoppingListView');
    final totalItems =
        lists.fold<int>(0, (sum, l) => sum + l.items.length);
    final sharedLists =
        lists.where((l) => l.sharedWithEmails.isNotEmpty).length;

    showDialog<void>(
      context: context,
      builder: (_) => AccountProfileModal(
        authController: widget.authController!,
        totalLists: lists.length,
        totalItems: totalItems,
        sharedLists: sharedLists,
      ),
    );
  }

  String? _getCurrentUserEmail() {
    if (widget.authController != null) {
      final state = widget.authController!.state;
      if (state is Authenticated) {
        return state.user.email;
      }
    }
    return null;
  }

  String _getDisplayName() {
    if (widget.authController != null) {
      final state = widget.authController!.state;
      if (state is Authenticated) {
        return state.user.displayName;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: widget.authController ?? ChangeNotifier(),
      builder: (context, _) {
        final authState = widget.authController?.state;
        final isUnauthenticated = authState is Unauthenticated;
        final isAuthLoading = authState is AuthLoading;

        return Scaffold(
          appBar: _buildAppBar(context, l10n),
          body: isAuthLoading
              ? const Center(child: CircularProgressIndicator())
              : (isUnauthenticated
                  ? _buildAuthGuard(context, l10n)
                  : ValueListenableBuilder<ShoppingListState>(
                      valueListenable: widget.controller,
                      builder: (context, state, _) {
                        if (state is ShoppingListLoading ||
                            state is ShoppingListInitial) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (state is ShoppingListError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.failure.message,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => widget.controller
                                      .loadShoppingLists(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is ShoppingListLoaded) {
                          if (state.lists.isEmpty) {
                            return _buildEmptyDashboard(context, l10n);
                          }
                          return _buildDashboard(
                              context, state.lists, l10n);
                        }

                        return const SizedBox.shrink();
                      },
                    )),
          floatingActionButton: isUnauthenticated || isAuthLoading
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _openCreateListModal(context),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(l10n?.newShoppingList ?? 'New List'),
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppLocalizations? l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_checkout_rounded,
            color: colorScheme.primary,
            size: 26,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              l10n?.appTitle ?? 'Shopping Explore',
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      centerTitle: true,
      elevation: 0,
      actions: [
        if (widget.authController != null)
          AuthUserButton(authController: widget.authController!),
        if (widget.onToggleLocale != null)
          IconButton(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language, size: 20),
                const SizedBox(width: 4),
                Text(
                  widget.currentLocale?.languageCode == 'he' ? 'HE' : 'EN',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            tooltip: 'Switch Language',
            onPressed: widget.onToggleLocale,
          ),
        if (widget.onToggleTheme != null)
          IconButton(
            icon: Icon(
              widget.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    List<ShoppingList> lists,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        // Greeting banner
        SliverToBoxAdapter(
          child: _buildGreetingBanner(context, lists, l10n),
        ),

        // Section title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: [
                Icon(
                  Icons.list_alt_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n?.allMyLists ?? 'All My Lists',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Grid of list cards
        SliverLayoutBuilder(
          builder: (context, constraints) {
            if (constraints.crossAxisExtent <= 0) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final list = lists[index];
                    return ShoppingListCard(
                      shoppingList: list,
                      onTap: () => _openListDetail(context, list),
                      onDelete: () {
                        widget.controller.deleteList(list.id);
                      },
                    );
                  },
                  childCount: lists.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
              ),
            );
          },
        ),

        // Bottom padding for FAB
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildGreetingBanner(
    BuildContext context,
    List<ShoppingList> lists,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayName = _getDisplayName();
    final totalItems =
        lists.fold<int>(0, (sum, l) => sum + l.items.length);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.08),
            colorScheme.secondary.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.isNotEmpty
                      ? '${l10n?.welcomeBack ?? 'Welcome back'},'
                      : l10n?.welcomeGuest ?? 'Welcome!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (displayName.isNotEmpty)
                  Text(
                    displayName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  '${lists.length} ${l10n?.listsCount ?? 'lists'} · $totalItems ${l10n?.itemsCount ?? 'items'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (widget.authController != null &&
              widget.authController!.state is Authenticated)
            GestureDetector(
              onTap: () => _openAccountProfile(context, lists),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  displayName.isNotEmpty
                      ? displayName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyDashboard(BuildContext context, AppLocalizations? l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_checkout_rounded,
              size: 40,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n?.noListsAvailable ?? 'No lists available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.createFirstList ?? 'Tap + to create your first shopping list!',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthGuard(BuildContext context, AppLocalizations? l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.primaryContainer.withValues(alpha: 0.15),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 36,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n?.authGuardTitle ?? 'Authentication Required',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n?.authGuardMessage ??
                    'Please sign in or create an account to view and manage your shopping lists.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (_) => LoginView(
                            authController: widget.authController!,
                            initialIsRegistering: false,
                          ),
                        );
                      },
                      icon: const Icon(Icons.login, size: 18),
                      label: Text(l10n?.signIn ?? 'Sign In'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (_) => LoginView(
                            authController: widget.authController!,
                            initialIsRegistering: true,
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: Text(l10n?.createAccount ?? 'Create Account'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ActionChip(
                avatar: const Icon(Icons.bug_report_rounded, size: 18),
                label: Text(l10n?.quickDebugGuyC ?? 'Quick Debug Login as Guy C'),
                backgroundColor: colorScheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
                onPressed: () {
                  widget.authController?.login('guy@shoppingexplore.com', 'password123', rememberMe: true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
