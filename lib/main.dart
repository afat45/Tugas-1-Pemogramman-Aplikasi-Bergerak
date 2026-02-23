import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ------------------------------------------------------------------
// DATA MODELS
// ------------------------------------------------------------------

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  // Ini untuk memperbaiki error "The getter 'price' isn't defined"
  double get price => product.price; 

  double get totalPrice => product.price * quantity;
}

// ------------------------------------------------------------------
// STATE MANAGEMENT (PROVIDER)
// ------------------------------------------------------------------

class StoreProvider extends ChangeNotifier {
  // --- 1. Data Dummy (40 Items) ---
final List<Product> _allProducts = List.generate(40, (index) {
    String category;
    String name;
    double price;

    // Logika pembuatan data dummy variatif
    if (index < 10) {
      category = 'Melee';
      name = [
        'Dragon Slayer Sword', 'Katana of Shadows', 'Viking Axe', 'Dagger of Venom',
        'Paladin Claymore', 'Rusty Iron Sword', 'Lightsaber Replica', 'Warhammer',
        'Spear of Destiny', 'Dual Blades'
      ][index];
      price = (index + 1) * 150000;
    } else if (index < 20) {
      category = 'Ranged';
      name = [
        'Elven Bow', 'Sniper Rifle MK-II', 'Crossbow heavy', 'Throwing Knives',
        'Plasma Pistol', 'Rocket Launcher', 'Slingshot', 'Compound Bow',
        'Desert Eagle Gold', 'Minigun'
      ][index - 10];
      price = (index + 1) * 200000;
    } else if (index < 30) {
      category = 'Magic';
      name = [
        'Fire Staff', 'Ice Wand', 'Necromancer Book', 'Orb of Light',
        'Thunder Scepter', 'Healing Amulet', 'Void Staff', 'Crystal Ball',
        'Magic Scroll', 'Enchanted Ring'
      ][index - 20];
      price = (index + 1) * 300000;
    } else {
      category = 'Armor';
      name = [
        'Knight Helmet', 'Dragon Chestplate', 'Leather Boots', 'Steel Gauntlets',
        'Mage Robe', 'Shield of Valor', 'Invisible Cloak', 'Heavy Greaves',
        'Obsidian Shield', 'Golden Crown'
      ][index - 30];
      price = (index + 1) * 100000;
    }

    return Product(
      id: 'p$index',
      name: name,
      category: category,
      price: price,
      // Menggunakan placeholder image yang reliable dengan text nama barang
      imageUrl: 'https://placehold.co/400x400/222222/FFFFFF/png?text=${name.replaceAll(" ", "+")}',
      description: 'High quality $name suitable for your battles.',
    );
  });

  // --- State Variables ---
  Map<String, CartItem> _cartItems = {};
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // --- Getters ---
  List<Product> get products {
    return _allProducts.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Map<String, CartItem> get cartItems => _cartItems;

  int get itemCount => _cartItems.length;

  double get totalAmount {
    var total = 0.0;
    _cartItems.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  List<String> get categories => ['All', 'Melee', 'Ranged', 'Magic', 'Armor'];
  String get currentCategory => _selectedCategory;

  // --- Actions ---

  // WAJIB: Add to cart
  void addToCart(Product product) {
    if (_cartItems.containsKey(product.id)) {
      _cartItems.update(
        product.id,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _cartItems.putIfAbsent(
        product.id,
        () => CartItem(product: product),
      );
    }
    notifyListeners();
  }

  // WAJIB: Update Quantity & Remove
  void removeSingleItem(String productId) {
    if (!_cartItems.containsKey(productId)) return;

    if (_cartItems[productId]!.quantity > 1) {
      _cartItems.update(
        productId,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _cartItems.remove(productId);
    }
    notifyListeners();
  }

  void removeItemFully(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems = {};
    notifyListeners();
  }

  // BONUS: Search & Filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}

// ------------------------------------------------------------------
// UI IMPLEMENTATION
// ------------------------------------------------------------------

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => StoreProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Legendary Armory',
      theme: ThemeData(
        primarySwatch: Colors.red, // Tema agresif untuk senjata
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D2D2D),
          foregroundColor: Colors.white,
        ),
      ),
      home: const ProductListScreen(),
    );
  }
}

// --- SCREEN 1: PRODUCT LIST (HOME) ---
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StoreProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚔️ Legendary Armory'),
        actions: [
          // Cart Icon with Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const CartScreen()),
                  );
                },
              ),
              if (store.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${store.itemCount}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // BONUS: Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Weapons...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (value) => store.setSearchQuery(value),
            ),
          ),
          // BONUS: Category Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: store.categories.length,
              itemBuilder: (ctx, index) {
                final cat = store.categories[index];
                final isSelected = cat == store.currentCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: Colors.redAccent,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    onSelected: (bool selected) {
                      store.setCategory(selected ? cat : 'All');
                    },
                  ),
                );
              },
            ),
          ),
          // WAJIB: Product List
          Expanded(
            child: store.products.isEmpty
                ? const Center(child: Text("No weapons found!"))
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7, // Aspek rasio kartu
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: store.products.length,
                    itemBuilder: (ctx, i) {
                      final product = store.products[i];
                      return ProductItem(product: product);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Widget Helper untuk Item Produk
class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StoreProvider>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            product.name,
            textAlign: TextAlign.center,
          ),
          subtitle: Text("Rp ${product.price.toStringAsFixed(0)}"),
          trailing: IconButton(
            icon: const Icon(Icons.add_shopping_cart, color: Colors.redAccent),
            onPressed: () {
              store.addToCart(product);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} added to cart!'),
                  duration: const Duration(seconds: 1),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () => store.removeSingleItem(product.id),
                  ),
                ),
              );
            },
          ),
        ),
        child: GestureDetector(
          onTap: () {
            // Bisa tambah detail page di sini
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (ctx, error, stackTrace) =>
                Container(color: Colors.grey, child: const Center(child: Icon(Icons.error))),
          ),
        ),
      ),
    );
  }
}

// --- SCREEN 2: CART SCREEN ---
class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StoreProvider>(context);
    final cartItems = store.cartItems.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Inventory (Cart)')),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text("Your cart is empty, warrior!"))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (ctx, i) {
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(cartItems[i].product.imageUrl),
                              backgroundColor: Colors.grey,
                            ),
                            title: Text(cartItems[i].product.name),
                            subtitle: Text(
                                'Total: Rp ${(cartItems[i].product.price * cartItems[i].quantity).toStringAsFixed(0)}'),
                            trailing: SizedBox(
                              width: 120,
                              child: Row(
                                children: [
                                  // WAJIB: Update Quantity (-)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      store.removeSingleItem(cartItems[i].product.id);
                                    },
                                  ),
                                  Text('${cartItems[i].quantity}'),
                                  // WAJIB: Update Quantity (+)
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      store.addToCart(cartItems[i].product);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // WAJIB: Display Total Price
          Card(
            margin: const EdgeInsets.all(15),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 20)),
                      Text(
                        'Rp ${store.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[800], // Background color
                        foregroundColor: Colors.white, // Text color
                      ),
                      onPressed: store.totalAmount <= 0
                          ? null
                          : () {
                              // Navigasi ke Checkout
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (ctx) => const CheckoutScreen()),
                              );
                            },
                      child: const Text('PROCEED TO CHECKOUT'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- SCREEN 3: CHECKOUT SCREEN (BONUS) ---
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<StoreProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              // BONUS: Order Summary
              ...store.cartItems.values.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.quantity}x ${item.product.name}'),
                        Text('Rp ${item.totalPrice.toStringAsFixed(0)}'),
                      ],
                    ),
                  )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total to Pay:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Rp ${store.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Shipping Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // BONUS: Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Address (Realm/City)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Gold Coins', child: Text('Gold Coins')),
                        DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
                        DropdownMenuItem(value: 'PayPal', child: Text('PayPal')),
                      ],
                      onChanged: (val) {},
                      initialValue: 'Gold Coins',
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Proses Order
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Order Successful!'),
                                content: const Text(
                                    'Your weapons are being prepared for shipment.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      store.clearCart(); // Bersihkan cart
                                      Navigator.of(ctx).pop(); // Tutup dialog
                                      Navigator.of(ctx).pop(); // Tutup checkout
                                      Navigator.of(ctx).pop(); // Kembali ke home
                                    },
                                    child: const Text('OK'),
                                  )
                                ],
                              ),
                            );
                          }
                        },
                        child: const Text('PLACE ORDER', style: TextStyle(fontSize: 16)),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}