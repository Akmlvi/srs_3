import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


const String appTitle = 'Магазин техники';

final ValueNotifier<ThemeMode> themeModeNotifier =
ValueNotifier<ThemeMode>(ThemeMode.light);

void showToast(String message) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
  );
}

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
          title: appTitle,
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: mode,
          home: const HomeScreen(),
        );
      },
    );
  }
}

// ------------------------------------------------------------
enum DrawerPage { home, profile, settings, other }

class AppDrawer extends StatelessWidget {
  final DrawerPage current;

  const AppDrawer({super.key, required this.current});

  void _openScreen(BuildContext context, DrawerPage page, Widget screen) {
    Navigator.pop(context);
    if (current == page) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
          (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text('Иван Иванов'),
            accountEmail: Text('ivan@example.com'),
            currentAccountPicture: CircleAvatar(
              child: Text('ИИ', style: TextStyle(fontSize: 24)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Главная'),
            selected: current == DrawerPage.home,
            onTap: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Профиль'),
            selected: current == DrawerPage.profile,
            onTap: () =>
                _openScreen(context, DrawerPage.profile, const ProfileScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Настройки'),
            selected: current == DrawerPage.settings,
            onTap: () => _openScreen(
                context, DrawerPage.settings, const SettingsScreen()),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Выход'),
            onTap: () {
              Navigator.pop(context);
              showToast('Выход из аккаунта');
            },
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _items = List.generate(10, (i) => 'Товар №${i + 1}');

  Future<void> _addItem() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const AddItemDialog(),
    );
    if (!mounted || name == null) return;
    setState(() => _items.add(name));
    showToast('Добавлено: $name');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          return Scaffold(
            appBar: AppBar(
              title: const Text(appTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.style),
                  tooltip: 'Карточки',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CardsScreen()),
                  ),
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.list), text: 'Список'),
                  Tab(icon: Icon(Icons.grid_view), text: 'Сетка'),
                ],
              ),
            ),
            drawer: const AppDrawer(current: DrawerPage.home),
            body: TabBarView(
              children: [
                ItemsList(items: _items),
                const GridTab(),
              ],
            ),
            floatingActionButton: ListenableBuilder(
              listenable: tabController.animation!,
              builder: (context, child) {
                if (tabController.animation!.value >= 0.5) {
                  return const SizedBox.shrink();
                }
                return FloatingActionButton(
                  onPressed: _addItem,
                  tooltip: 'Добавить элемент',
                  child: const Icon(Icons.add),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------
class ItemsList extends StatelessWidget {
  final List<String> items;

  const ItemsList({super.key, required this.items});

  static const List<IconData> _icons = [
    Icons.shopping_bag,
    Icons.laptop,
    Icons.headphones,
    Icons.watch,
    Icons.camera_alt,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final title = items[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Icon(_icons[index % _icons.length])),
            title: Text(title),
            subtitle: Text('Описание товара, элемент №${index + 1}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showToast('Вы выбрали: $title'),
          ),
        );
      },
    );
  }
}
class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      showToast('Введите название');
      return;
    }
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новый элемент'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Название'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Добавить')),
      ],
    );
  }
}

// ------------------------------------------------------------
class GridTab extends StatefulWidget {
  const GridTab({super.key});

  @override
  State<GridTab> createState() => _GridTabState();
}

class _GridTabState extends State<GridTab>
    with AutomaticKeepAliveClientMixin {
  static const List<Color> _colors = [
    Colors.blue,
    Colors.deepPurple,
    Colors.orange,
    Colors.pink,
    Colors.red,
    Colors.cyan,
    Colors.brown,
    Colors.blueGrey,
    Colors.indigo,
    Colors.amber,
    Colors.purple,
    Colors.teal,
  ];

  final List<bool> _pressed = List<bool>.filled(_colors.length, false);

  @override
  bool get wantKeepAlive => true; // сохраняем состояние при смене вкладки

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _colors.length,
      itemBuilder: (context, index) {
        final pressed = _pressed[index];
        return GestureDetector(
          onTap: () {
            setState(() => _pressed[index] = !_pressed[index]);
            showToast('Вы нажали на плитку №${index + 1}');
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: pressed ? Colors.green : _colors[index],
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------
class Product {
  final String name;
  final String description;
  final String details;
  final String price;
  final String imageUrl;

  const Product({
    required this.name,
    required this.description,
    required this.details,
    required this.price,
    required this.imageUrl,
  });
}

const List<Product> products = [
  Product(
    name: 'Смартфон',
    description: 'Современный смартфон с ярким экраном и отличной камерой.',
    details:
    'Экран AMOLED 6,5", 8 ГБ ОЗУ, 256 ГБ памяти, тройная камера 50 Мп, '
        'аккумулятор 5000 мАч с быстрой зарядкой.',
    price: '39 990 ₽',
    imageUrl: 'https://picsum.photos/seed/smartphone/600/360',
  ),
  Product(
    name: 'Ноутбук',
    description: 'Лёгкий ноутбук для учёбы и работы.',
    details:
    'Процессор 8 ядер, 16 ГБ ОЗУ, SSD 512 ГБ, экран 14" IPS, '
        'до 12 часов автономной работы, вес 1,3 кг.',
    price: '69 990 ₽',
    imageUrl: 'https://picsum.photos/seed/laptop/600/360',
  ),
  Product(
    name: 'Наушники',
    description: 'Беспроводные наушники с шумоподавлением.',
    details:
    'Bluetooth 5.3, активное шумоподавление, до 30 часов работы с кейсом, '
        'защита от влаги IPX4.',
    price: '7 990 ₽',
    imageUrl: 'https://picsum.photos/seed/headphones/600/360',
  ),
  Product(
    name: 'Умные часы',
    description: 'Фитнес-трекер и уведомления на запястье.',
    details:
    'Пульсометр, GPS, датчик кислорода в крови, водонепроницаемость 5 ATM, '
        'до 10 дней без подзарядки.',
    price: '12 490 ₽',
    imageUrl: 'https://picsum.photos/seed/smartwatch/600/360',
  ),
  Product(
    name: 'Фотоаппарат',
    description: 'Компактная камера для путешествий.',
    details:
    'Матрица 24 Мп, оптический зум 10x, запись видео 4K, '
        'Wi-Fi для быстрой передачи снимков.',
    price: '45 500 ₽',
    imageUrl: 'https://picsum.photos/seed/camera/600/360',
  ),
];
class ProductImage extends StatelessWidget {
  final String url;
  final double height;

  const ProductImage({super.key, required this.url, required this.height});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: scheme.secondaryContainer,
          alignment: Alignment.center,
          child: Icon(Icons.image, size: 48, color: scheme.onSecondaryContainer),
        ),
      ),
    );
  }
}

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Карточки')),
      drawer: const AppDrawer(current: DrawerPage.other),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: products.length,
        itemBuilder: (context, index) => ProductCard(product: products[index]),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _favorite = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImage(url: product.imageUrl, height: 160),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(product.name, style: textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(product.description),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'В избранное',
                  icon: Icon(
                    _favorite ? Icons.favorite : Icons.favorite_border,
                    color: _favorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    setState(() => _favorite = !_favorite);
                    showToast(_favorite
                        ? 'Добавлено в избранное: ${product.name}'
                        : 'Удалено из избранного: ${product.name}');
                  },
                ),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(product: product),
                    ),
                  ),
                  child: const Text('Подробнее'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImage(url: product.imageUrl, height: 240),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    product.price,
                    style: textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(product.description),
                  const SizedBox(height: 12),
                  Text(product.details),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          showToast('${product.name} добавлен в корзину'),
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('В корзину'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// ------------------------------------------------------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      drawer: const AppDrawer(current: DrawerPage.profile),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 56,
              child: Icon(Icons.person, size: 64),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text('Иван Иванов', style: textTheme.titleLarge)),
          const SizedBox(height: 4),
          const Center(child: Text('ivan@example.com')),
          const SizedBox(height: 24),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.badge),
                  title: Text('Имя'),
                  subtitle: Text('Иван Иванов'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Email'),
                  subtitle: Text('ivan@example.com'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.school),
                  title: Text('Роль'),
                  subtitle: Text('Студент'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: () => showToast('Hello, Flutter!'),
              icon: const Icon(Icons.waving_hand),
              label: const Text('Показать приветствие'),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _rememberChoice = false;
  double _volume = 50;

  @override
  Widget build(BuildContext context) {
    final isDark = themeModeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      drawer: const AppDrawer(current: DrawerPage.settings),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: const Text('Уведомления'),
                  value: _notifications,
                  onChanged: (value) => setState(() => _notifications = value),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text('Тёмная тема'),
                  value: isDark,
                  onChanged: (value) {
                    themeModeNotifier.value =
                    value ? ThemeMode.dark : ThemeMode.light;
                    setState(() {});
                  },
                ),
                CheckboxListTile(
                  secondary: const Icon(Icons.history),
                  title: const Text('Запоминать выбор'),
                  value: _rememberChoice,
                  onChanged: (value) =>
                      setState(() => _rememberChoice = value ?? false),
                ),
              ],
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Громкость: ${_volume.round()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _volume,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: _volume.round().toString(),
                    onChanged: (value) => setState(() => _volume = value),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: () => showToast('Настройки сохранены'),
              icon: const Icon(Icons.save),
              label: const Text('Сохранить'),
            ),
          ),
        ],
      ),
    );
  }
}