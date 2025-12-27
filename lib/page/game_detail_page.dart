import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:gaming_shop/model/game_model.dart';
import 'package:gaming_shop/services/api_service.dart';
import 'package:gaming_shop/utils/storage_helper.dart';
import 'package:gaming_shop/page/topup_page.dart';
import 'package:gaming_shop/page/login_page.dart';

@RoutePage()
class GameDetailPage extends StatefulWidget {
  final GameModel? game;
  final String? gameId;

  const GameDetailPage({super.key, this.game, @PathParam('id') this.gameId});

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _serverIdController = TextEditingController();
  bool _isValidating = false;
  String? _validationMessage;
  bool? _isValid;
  String? _playerName;
  Catalogues? _selectedCatalogue;

  GameModel? _gameData;
  bool _isLoading = false;
  bool _hasServerIdField = false;
  String? _fieldNotes;

  @override
  void initState() {
    super.initState();
    if (widget.game != null) {
      _gameData = widget.game;
      _loadFieldsData();
    } else if (widget.gameId != null) {
      _loadGameData();
    }
  }

  Future<void> _loadGameData() async {
    setState(() => _isLoading = true);

    try {
      final games = await ApiService.Products();
      final gameModel = games.firstWhere(
        (game) => game.sId == widget.gameId,
        orElse: () => throw Exception('Game not found'),
      );

      setState(() {
        _gameData = gameModel;
        _isLoading = false;
      });
      
      await _loadFieldsData();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadFieldsData() async {
    if (_gameData?.game?.code == null) return;

    try {
      final fieldsData = await ApiService.getProductFields(_gameData!.game!.code!);
      if (fieldsData != null) {
        setState(() {
          final fields = fieldsData['fields'] as List?;
          _hasServerIdField = fields?.any((field) => 
            field.toString().toLowerCase() == 'serverid' || 
            field.toString().toLowerCase() == 'zoneid'
          ) ?? false;
          _fieldNotes = fieldsData['notes'];
        });
      }
    } catch (e) {
      print('Error loading fields: $e');
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _serverIdController.dispose();
    super.dispose();
  }

  String _formatAmount(int? amount) {
    if (amount == null) return '0';
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  bool _isNumericName(String? name) {
    if (name == null) return false;
    // Check if name contains only digits and common separators
    final cleanName = name.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanName.isNotEmpty && cleanName.length >= name.length * 0.5;
  }

  String _getCurrencyName() {
    final gameCode = _gameData?.game?.code?.toLowerCase() ?? '';
    
    if (gameCode.contains('pubg')) {
      return 'UC';
    } else if (gameCode.contains('mlbb') || gameCode.contains('mobile') || gameCode.contains('magic')) {
      return 'Diamonds';
    } else if (gameCode.contains('hok') || gameCode.contains('honor')) {
      return 'Tokens';
    } else if (gameCode.contains('cod') || gameCode.contains('codm')) {
      return 'CP';
    } else if (gameCode.contains('ff') || gameCode.contains('freefire')) {
      return 'Diamonds';
    } else if (gameCode.contains('genshin')) {
      return 'Genesis Crystals';
    } else if (gameCode.contains('valorant')) {
      return 'VP';
    } else if (gameCode.contains('lol') || gameCode.contains('league')) {
      return 'RP';
    } else if (gameCode.contains('bigo')) {
      return 'Diamonds';
    } else if (gameCode.contains('poppo')) {
      return 'Coins';
    }
    
    return '';
  }

  Future<void> _validatePlayerId() async {
    if (_gameData == null) return;

    if (_userIdController.text.isEmpty) {
      setState(() {
        _validationMessage = 'Please enter User ID';
        _isValid = false;
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _validationMessage = null;
      _isValid = null;
      _playerName = null;
    });

    final result = await ApiService.checkPlayerId(
      game: _gameData!.game?.code ?? '',
      userId: _userIdController.text,
      serverId: _serverIdController.text.isNotEmpty
          ? _serverIdController.text
          : null,
    );

    setState(() {
      _isValidating = false;
      _isValid = result['success'];
      if (result['success']) {
        final data = result['data'];
        _playerName = data?['name'];
        
        // Check if player name is "na" or "N/A"
        if (_playerName != null && 
            (_playerName!.toLowerCase() == 'na' || 
             _playerName!.toLowerCase() == 'n/a')) {
          _isValid = false;
          _validationMessage = 'Player ID not found or invalid';
          _playerName = null;
        } else if (_playerName != null) {
          _validationMessage = 'Player: $_playerName';
        } else {
          _validationMessage = 'Player ID verified successfully!';
        }
      } else {
        _playerName = null;
        _validationMessage = result['message'] ?? 'Validation failed';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_gameData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Game not found')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _gameData!.game?.imageUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.videogame_asset_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Game Name
                  Text(
                    _gameData!.game?.name ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tag
                  if (_gameData!.tag != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF08652C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF08652C).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _gameData!.tag!,
                        style: const TextStyle(
                          color: Color(0xFF08652C),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // User ID & Server ID Fields in Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          'User ID',
                          'Enter User ID',
                          _userIdController,
                        ),
                      ),
                      if (_hasServerIdField) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            'Server ID',
                            'Server ID (optional)',
                            _serverIdController,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Notes
                  if (_fieldNotes != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _fieldNotes!,
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Validate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isValidating ? null : _validatePlayerId,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF08652C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isValidating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Validate Player ID',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  // Validation Message
                  if (_validationMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isValid == true
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isValid == true
                              ? Colors.green.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isValid == true ? Icons.check_circle : Icons.error,
                            color: _isValid == true ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _validationMessage!,
                              style: TextStyle(
                                fontSize: 13,
                                color: _isValid == true
                                    ? Colors.green[800]
                                    : Colors.red[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Twilight & Weekly Pass Section
                  if (_gameData!.catalogues != null &&
                      _gameData!.catalogues!.isNotEmpty) ...[
                    Builder(
                      builder: (context) {
                        final twilightWeekly = _gameData!.catalogues!.where((
                          cat,
                        ) {
                          final name = cat.name?.toLowerCase() ?? '';
                          return name.contains('twilight') ||
                              name.contains('weekly');
                        }).toList();

                        if (twilightWeekly.isEmpty)
                          return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Twilight & Weekly Pass',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...twilightWeekly.map((catalogue) {
                              final isSelected =
                                  _selectedCatalogue?.sId == catalogue.sId;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCatalogue = catalogue;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFF08652C),
                                              Color(0xFF0A7A35),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: isSelected ? null : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF08652C)
                                          : Colors.grey[200]!,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? const Color(
                                                0xFF08652C,
                                              ).withOpacity(0.3)
                                            : Colors.black.withOpacity(0.06),
                                        blurRadius: isSelected ? 16 : 8,
                                        offset: Offset(0, isSelected ? 4 : 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                catalogue.name ?? '',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'ID: ${catalogue.id}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: isSelected
                                                      ? Colors.white
                                                            .withOpacity(0.9)
                                                      : Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${_formatAmount(catalogue.amount)} Ks',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF08652C),
                                          ),
                                        ),
                                        if (isSelected) ...[
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Icon(
                                              Icons.check_circle,
                                              color: Color(0xFF08652C),
                                              size: 24,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),

                    const Text(
                      'Available Packages',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...() {
                      final allCatalogues = _gameData!.catalogues!
                          .where((cat) {
                            final name = cat.name?.toLowerCase() ?? '';
                            return !name.contains('twilight') &&
                                !name.contains('weekly');
                          })
                          .toList();

                      final numericCatalogues = allCatalogues
                          .where((cat) => _isNumericName(cat.name))
                          .toList();

                      final primeCatalogues = allCatalogues
                          .where((cat) {
                            final name = cat.name?.toLowerCase() ?? '';
                            return !_isNumericName(cat.name) &&
                                name.contains('prime') &&
                                !name.contains('plus') &&
                                !name.contains('elite');
                          })
                          .toList();

                      final primePlusCatalogues = allCatalogues
                          .where((cat) {
                            final name = cat.name?.toLowerCase() ?? '';
                            return !_isNumericName(cat.name) &&
                                name.contains('plus') &&
                                !name.contains('elite');
                          })
                          .toList();

                      final eliteCatalogues = allCatalogues
                          .where((cat) {
                            final name = cat.name?.toLowerCase() ?? '';
                            return !_isNumericName(cat.name) &&
                                name.contains('elite');
                          })
                          .toList();

                      final levelUpCatalogues = allCatalogues
                          .where((cat) {
                            final name = cat.name?.toLowerCase() ?? '';
                            return !_isNumericName(cat.name) &&
                                (name.contains('level') || name.contains('lvl'));
                          })
                          .toList();

                      final evoAccessCatalogues = allCatalogues
                          .where((cat) {
                            final name = cat.name?.toLowerCase() ?? '';
                            return !_isNumericName(cat.name) &&
                                name.contains('evo');
                          })
                          .toList();

                      final otherCatalogues = allCatalogues
                          .where((cat) {
                            final name = cat.name?.toLowerCase() ?? '';
                            return !_isNumericName(cat.name) &&
                                !name.contains('prime') &&
                                !name.contains('plus') &&
                                !name.contains('elite') &&
                                !name.contains('level') &&
                                !name.contains('lvl') &&
                                !name.contains('evo');
                          })
                          .toList();

                      List<Widget> widgets = [];

                      // Add numeric catalogues
                      for (var catalogue in numericCatalogues) {
                        final isSelected =
                            _selectedCatalogue?.sId == catalogue.sId;
                        widgets.add(
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCatalogue = catalogue;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF08652C),
                                          Color(0xFF0A7A35),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF08652C)
                                      : Colors.grey[200]!,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? const Color(
                                            0xFF08652C,
                                          ).withOpacity(0.3)
                                        : Colors.black.withOpacity(0.06),
                                    blurRadius: isSelected ? 16 : 8,
                                    offset: Offset(0, isSelected ? 4 : 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${catalogue.name ?? ''}${_getCurrencyName().isNotEmpty ? ' ${_getCurrencyName()}' : ''}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'ID: ${catalogue.id}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.white.withOpacity(
                                                      0.9,
                                                    )
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${_formatAmount(catalogue.amount)} Ks',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF08652C),
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF08652C),
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      // Add Prime section if there are prime catalogues
                      if (primeCatalogues.isNotEmpty) {
                        widgets.add(
                          const Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 12),
                            child: Text(
                              'Prime',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        );

                        for (var catalogue in primeCatalogues) {
                          final isSelected =
                              _selectedCatalogue?.sId == catalogue.sId;
                          widgets.add(
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCatalogue = catalogue;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF08652C),
                                            Color(0xFF0A7A35),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF08652C)
                                        : Colors.grey[200]!,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? const Color(
                                              0xFF08652C,
                                            ).withOpacity(0.3)
                                          : Colors.black.withOpacity(0.06),
                                      blurRadius: isSelected ? 16 : 8,
                                      offset: Offset(0, isSelected ? 4 : 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              catalogue.name ?? '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'ID: ${catalogue.id}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isSelected
                                                    ? Colors.white.withOpacity(
                                                        0.9,
                                                      )
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${_formatAmount(catalogue.amount)} Ks',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF08652C),
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF08652C),
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }

                      // Add Prime Plus section if there are prime plus catalogues
                      if (primePlusCatalogues.isNotEmpty) {
                        widgets.add(
                          const Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 12),
                            child: Text(
                              'Prime Plus',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        );

                        for (var catalogue in primePlusCatalogues) {
                          final isSelected =
                              _selectedCatalogue?.sId == catalogue.sId;
                          widgets.add(
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCatalogue = catalogue;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF08652C),
                                            Color(0xFF0A7A35),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF08652C)
                                        : Colors.grey[200]!,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? const Color(
                                              0xFF08652C,
                                            ).withOpacity(0.3)
                                          : Colors.black.withOpacity(0.06),
                                      blurRadius: isSelected ? 16 : 8,
                                      offset: Offset(0, isSelected ? 4 : 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              catalogue.name ?? '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'ID: ${catalogue.id}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isSelected
                                                    ? Colors.white.withOpacity(
                                                        0.9,
                                                      )
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${_formatAmount(catalogue.amount)} Ks',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF08652C),
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF08652C),
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }

                      // Add Elite Pass section if there are elite catalogues
                      if (eliteCatalogues.isNotEmpty) {
                        widgets.add(
                          const Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 12),
                            child: Text(
                              'Elite Pass',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        );

                        for (var catalogue in eliteCatalogues) {
                          final isSelected =
                              _selectedCatalogue?.sId == catalogue.sId;
                          widgets.add(
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCatalogue = catalogue;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF08652C),
                                            Color(0xFF0A7A35),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF08652C)
                                        : Colors.grey[200]!,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? const Color(
                                              0xFF08652C,
                                            ).withOpacity(0.3)
                                          : Colors.black.withOpacity(0.06),
                                      blurRadius: isSelected ? 16 : 8,
                                      offset: Offset(0, isSelected ? 4 : 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              catalogue.name ?? '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'ID: ${catalogue.id}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isSelected
                                                    ? Colors.white.withOpacity(
                                                        0.9,
                                                      )
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${_formatAmount(catalogue.amount)} Ks',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF08652C),
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF08652C),
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }

                      // Add Level Up section if there are level up catalogues
                      if (levelUpCatalogues.isNotEmpty) {
                        widgets.add(
                          const Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 12),
                            child: Text(
                              'Level Up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        );

                        for (var catalogue in levelUpCatalogues) {
                          final isSelected =
                              _selectedCatalogue?.sId == catalogue.sId;
                          widgets.add(
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCatalogue = catalogue;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF08652C),
                                            Color(0xFF0A7A35),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF08652C)
                                        : Colors.grey[200]!,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? const Color(
                                              0xFF08652C,
                                            ).withOpacity(0.3)
                                          : Colors.black.withOpacity(0.06),
                                      blurRadius: isSelected ? 16 : 8,
                                      offset: Offset(0, isSelected ? 4 : 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              catalogue.name ?? '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'ID: ${catalogue.id}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isSelected
                                                    ? Colors.white.withOpacity(
                                                        0.9,
                                                      )
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${_formatAmount(catalogue.amount)} Ks',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF08652C),
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF08652C),
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }

                      // Add Evo Access section if there are evo access catalogues
                      if (evoAccessCatalogues.isNotEmpty) {
                        widgets.add(
                          const Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 12),
                            child: Text(
                              'Evo Access',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        );

                        for (var catalogue in evoAccessCatalogues) {
                          final isSelected =
                              _selectedCatalogue?.sId == catalogue.sId;
                          widgets.add(
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCatalogue = catalogue;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF08652C),
                                            Color(0xFF0A7A35),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF08652C)
                                        : Colors.grey[200]!,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? const Color(
                                              0xFF08652C,
                                            ).withOpacity(0.3)
                                          : Colors.black.withOpacity(0.06),
                                      blurRadius: isSelected ? 16 : 8,
                                      offset: Offset(0, isSelected ? 4 : 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              catalogue.name ?? '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'ID: ${catalogue.id}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isSelected
                                                    ? Colors.white.withOpacity(
                                                        0.9,
                                                      )
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${_formatAmount(catalogue.amount)} Ks',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF08652C),
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF08652C),
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }

                      // Add Other section if there are other non-numeric catalogues
                      if (otherCatalogues.isNotEmpty) {
                        widgets.add(
                          const Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 12),
                            child: Text(
                              'Other',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        );

                        for (var catalogue in otherCatalogues) {
                          final isSelected =
                              _selectedCatalogue?.sId == catalogue.sId;
                          widgets.add(
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCatalogue = catalogue;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF08652C),
                                            Color(0xFF0A7A35),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF08652C)
                                        : Colors.grey[200]!,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? const Color(
                                              0xFF08652C,
                                            ).withOpacity(0.3)
                                          : Colors.black.withOpacity(0.06),
                                      blurRadius: isSelected ? 16 : 8,
                                      offset: Offset(0, isSelected ? 4 : 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              catalogue.name ?? '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'ID: ${catalogue.id}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isSelected
                                                    ? Colors.white.withOpacity(
                                                        0.9,
                                                      )
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${_formatAmount(catalogue.amount)} Ks',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF08652C),
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF08652C),
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }

                      return widgets;
                    }(),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _selectedCatalogue == null
              ? null
              : () async {
                  await _createOrder();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF08652C),
            disabledBackgroundColor: Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            _selectedCatalogue == null
                ? 'Select a Package'
                : 'Order Now - ${_formatAmount(_selectedCatalogue!.amount)} Ks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _selectedCatalogue == null
                  ? Colors.grey[600]
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createOrder() async {
    if (_selectedCatalogue == null) return;

    if (_userIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter User ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isValid != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please validate your Player ID first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Creating order...'),
              ],
            ),
          ),
        ),
      ),
    );

    final token = await StorageHelper.getToken();

    if (token == null) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login first'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final result = await ApiService.createOrder(
      token: token,
      productCode: _gameData!.game?.code ?? '',
      catalogueName: _selectedCatalogue!.name ?? '',
      playerId: _userIdController.text,
      serverId: _serverIdController.text.isNotEmpty
          ? _serverIdController.text
          : null,
    );

    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      if (result['success']) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Order Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your order has been placed successfully!'),
                const SizedBox(height: 12),
                Text(
                  'Order ID: ${result['data']?['_id'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to home
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        final errorMessage = result['message'] ?? 'Failed to create order';

        // Check if insufficient balance
        if (errorMessage.toLowerCase().contains('insufficient') ||
            errorMessage.toLowerCase().contains('balance')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Insufficient Balance'),
                ],
              ),
              content: const Text(
                'You don\'t have enough balance to complete this order. Would you like to top up now?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TopupPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF08652C),
                  ),
                  child: const Text(
                    'Top Up',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF08652C), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
