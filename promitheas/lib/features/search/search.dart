import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:promitheas/core/router/router_names.dart';
import 'package:promitheas/core/theme/app_colors.dart';
import 'package:promitheas/features/search/repositories/search_repository.dart';
import 'package:promitheas/shared/models/product_summary.dart';
import 'package:promitheas/shared/widgets/page_header.dart';
import 'package:promitheas/shared/widgets/product_card.dart';

//=============================================================================
//                            PANTALLA DE BÚSQUEDA
//==============================================================================
// Pantalla de búsqueda con resultados en tiempo real y manejo de estados de carga y vacíos.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

//=============================================================================
//                            ESTADO DE LA PANTALLA DE BÚSQUEDA
//=============================================================================
class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();  // Controlador del campo de búsqueda  
  List<ProductSummary>? _results; // Lista de resultados obtenidos de la búsqueda
  String _input = ''; // Cadena de texto actual en el campo de búsqueda
  bool _isLoading = false; // Indicador de si se está realizando una búsqueda
  Timer? _debounce; // Temporizador para implementar debounce en la búsqueda
  int _searchRequestId = 0; // Identificador incremental para cada solicitud de búsqueda, utilizado para evitar condiciones de carrera

  // Limpia los recursos al desmontar el widget
  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Construye la interfaz de usuario de la pantalla de búsqueda
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            //--------------------------------------------------------
            //                  Encabezado
            //--------------------------------------------------------
            const PageHeader(icon: Icons.search_rounded, title: 'SEARCH'),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE7E7EC)),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                
                //--------------------------------------------------------
                //                  Barra de búsqueda
                //--------------------------------------------------------
                child: TextField(
                  controller: _searchController,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color.fromARGB(255, 115, 115, 125),
                    fontWeight: FontWeight.w600,
                  ),
                  onChanged: _onSearchFieldChanged,
                  autocorrect: false,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search products, stores or categories',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color.fromARGB(255, 115, 115, 125),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: _input.isEmpty
                        ? null
                        : IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _buildSubtitle(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  // Construye el widget que muestra los resultados de la búsqueda o los estados de carga/vacío
  Widget _buildResults() {
    // Muestra un indicador de carga mientras se realiza la búsqueda
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryFire),
      );
    }
    // Muestra un placeholder cuando no hay resultados (estado inicial o después de limpiar la búsqueda)
    if (_results == null) {
      return _SearchPlaceholder(
        icon: Icons.manage_search_rounded,
        title: 'Find the best products quickly',
        description:
            'Start typing to explore products, stores and categories in Promitheas.',
      );
    }
    // Muestra un mensaje cuando la búsqueda no arroja resultados
    if (_results!.isEmpty) {
      return _SearchPlaceholder(
        icon: Icons.search_off_rounded,
        title: 'No matches found',
        description: 'Try another term for "$_input".',
      );
    }
    // Muestra la lista de resultados en una cuadrícula
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: _results!.length,
      itemBuilder: (context, index) {
        final product = _results![index];
        
        return LayoutBuilder(
          builder: (context, constraints) {
            return ProductCard(
              product: product,
              width: constraints.maxWidth,
              imageHeight: 88,
              onTap: () {
                context.go(RouteNames.productDetailPath(product.id.toString()));
              },
            );
          },
        );
      },
    );
  }

  // Maneja los cambios en el campo de búsqueda con debounce para evitar búsquedas excesivas
  Future<void> _onSearchFieldChanged(String value) async {
    _debounce?.cancel();

    setState(() {
      _input = value;
    });

    if (value.trim().isEmpty) {
      setState(() {
        _results = null;
        _isLoading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch(value);
    });
  }
  // Realiza la búsqueda llamando al repositorio y maneja la respuesta para actualizar el estado de la pantalla
  Future<void> _performSearch(String value) async {
    final requestId = ++_searchRequestId;

    setState(() {
      _isLoading = true;
    });

    final repository = ref.read(searchRepositoryProvider);
    final results = await repository.searchProducts(value);

    if (!mounted || requestId != _searchRequestId) {
      return;
    }

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }
  // Limpia el campo de búsqueda y restablece el estado de resultados e indicadores
  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _input = '';
      _results = null;
      _isLoading = false;
    });
  }
  // Construye el subtítulo que muestra el estado actual de la búsqueda (cargando, sin resultados o número de resultados)
  String _buildSubtitle() {
    if (_isLoading) {
      return 'Searching...';
    }

    if (_results == null) {
      return 'Search across the catalog';
    }

    return '${_results!.length} results for "$_input"';
  }
}
//  Widget para mostrar estados de búsqueda vacíos o sin resultados, con un ícono, título y descripción contextualizados.
class _SearchPlaceholder extends StatelessWidget {
  const _SearchPlaceholder({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryFire.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, color: AppColors.primaryFire, size: 34),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primaryFire,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
