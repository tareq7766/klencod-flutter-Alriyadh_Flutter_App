import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../models/product.dart';
import '../services/product_store.dart';

const String factoryPhone = '773766177';
const String factoryLocation = 'صنعاء، المطار، خط العروق';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ProductStore _store = ProductStore();
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _store.loadProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _saveProducts() async {
    await _store.saveProducts(_products);
  }

  Future<void> _openUri(Uri uri) async {
    try {
      final ok = await canLaunchUrl(uri);
      if (ok) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح التطبيق المطلوب على هذا الجهاز.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء فتح الرابط.')),
        );
      }
    }
  }

  Future<void> _callFactory() => _openUri(Uri(scheme: 'tel', path: factoryPhone));

  Future<void> _whatsappFactory() =>
      _openUri(Uri.parse('https://wa.me/967$factoryPhone'));

  Future<void> _openMap() => _openUri(Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(factoryLocation)}'));

  Future<void> _openAdmin() async {
    final changed = await Navigator.of(context).push<List<Product>>(
      MaterialPageRoute(
        builder: (_) => AdminScreen(initialProducts: List<Product>.from(_products)),
      ),
    );
    if (changed != null) {
      setState(() => _products = changed);
      await _saveProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homePage(),
      _productsPage(),
      _contactPage(),
      _aboutPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('مصنع الرياض للبلك الأوتوماتيكي',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'إدارة المنتجات',
            onPressed: _openAdmin,
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.view_module_outlined), selectedIcon: Icon(Icons.view_module), label: 'المنتجات'),
          NavigationDestination(icon: Icon(Icons.call_outlined), selectedIcon: Icon(Icons.call), label: 'التواصل'),
          NavigationDestination(icon: Icon(Icons.factory_outlined), selectedIcon: Icon(Icons.factory), label: 'عن المصنع'),
        ],
      ),
    );
  }

  Widget _homePage() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AlriyadhApp.cement, Color(0xFF56636B)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.domain, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                const Text('مصنع الرياض\nللبلك الأوتوماتيكي',
                    style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w800, height: 1.35)),
                const SizedBox(height: 10),
                const Text('بلك قوي ومتين، جودة تعتمد عليها',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 22),
                Wrap(spacing: 10, runSpacing: 10, children: [
                  FilledButton.icon(
                    onPressed: _callFactory,
                    icon: const Icon(Icons.call),
                    label: const Text('اتصل بالمصنع'),
                    style: FilledButton.styleFrom(backgroundColor: AlriyadhApp.orange, foregroundColor: Colors.white),
                  ),
                  OutlinedButton.icon(
                    onPressed: _whatsappFactory,
                    icon: const Icon(Icons.chat),
                    label: const Text('واتساب'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white70)),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'لماذا مصنع الرياض؟'),
          const SizedBox(height: 10),
          const Row(children: [
            Expanded(child: _FeatureCard(icon: Icons.precision_manufacturing, title: 'إنتاج أوتوماتيكي', subtitle: 'تصنيع منظم')),
            SizedBox(width: 10),
            Expanded(child: _FeatureCard(icon: Icons.verified_outlined, title: 'اهتمام بالجودة', subtitle: 'تركيز على المتانة')),
          ]),
          const SizedBox(height: 18),
          _SectionTitle(
            title: 'منتجاتنا',
            trailing: TextButton(onPressed: () => setState(() => _selectedIndex = 1), child: const Text('عرض الكل')),
          ),
          const SizedBox(height: 10),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else if (_products.isEmpty)
            const _EmptyProducts()
          else
            ..._products.take(3).map(_productCard),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.location_on_outlined)),
              title: const Text('موقع المصنع', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text(factoryLocation),
              trailing: IconButton(onPressed: _openMap, icon: const Icon(Icons.directions)),
              onTap: _openMap,
            ),
          ),
        ],
      );

  Widget _productsPage() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('منتجات البلك الأسمنتي', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('تُعرض الأسعار فقط بعد إدخالها من إدارة التطبيق.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_products.isEmpty)
            const _EmptyProducts()
          else
            ..._products.map(_productCard),
        ],
      );

  Widget _productCard(Product product) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(color: const Color(0xFFE8E5E0), borderRadius: BorderRadius.circular(14)),
                child: product.imageUrl != null && product.imageUrl!.trim().isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(product.imageUrl!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.view_module, size: 38, color: AlriyadhApp.cement)),
                      )
                    : const Icon(Icons.view_module, size: 38, color: AlriyadhApp.cement),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(product.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  if (product.size.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('المقاس: ${product.size}', style: const TextStyle(color: Colors.black54)),
                  ],
                  if (product.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(product.description),
                  ],
                  if (product.price != null && product.price!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('السعر: ${product.price}', style: const TextStyle(color: AlriyadhApp.orange, fontWeight: FontWeight.bold)),
                  ],
                ]),
              ),
            ],
          ),
        ),
      );

  Widget _contactPage() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('تواصل معنا', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('يسعدنا استقبال استفساراتكم عن المنتجات والتوريد.'),
          const SizedBox(height: 18),
          _ContactTile(icon: Icons.phone, title: 'رقم الهاتف', subtitle: factoryPhone, onTap: _callFactory),
          const SizedBox(height: 10),
          _ContactTile(icon: Icons.chat, title: 'واتساب', subtitle: 'فتح محادثة مباشرة', onTap: _whatsappFactory),
          const SizedBox(height: 10),
          _ContactTile(icon: Icons.location_on, title: 'العنوان', subtitle: factoryLocation, onTap: _openMap),
          const SizedBox(height: 18),
          FilledButton.icon(onPressed: _callFactory, icon: const Icon(Icons.call), label: const Text('اتصال مباشر')),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _whatsappFactory,
            icon: const Icon(Icons.chat),
            label: const Text('التواصل عبر واتساب'),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF247B4B)),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: _openMap, icon: const Icon(Icons.map_outlined), label: const Text('فتح الموقع على خرائط Google')),
        ],
      );

  Widget _aboutPage() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(color: const Color(0xFFE4E0D9), borderRadius: BorderRadius.circular(22)),
            child: const Center(child: Icon(Icons.factory, size: 72, color: AlriyadhApp.cement)),
          ),
          const SizedBox(height: 18),
          const Text('عن المصنع', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            'مصنع الرياض للبلك الأوتوماتيكي في صنعاء، اليمن، متخصص في إنتاج البلك الأسمنتي. '
            'يركز المصنع على الجودة والمتانة والإنتاج الأوتوماتيكي لتلبية احتياجات مشاريع البناء.',
            style: TextStyle(fontSize: 16, height: 1.7),
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'معرض الصور'),
          const SizedBox(height: 8),
          const Text('يمكن إضافة صور المصنع والبلك والشاحنات لاحقًا من خلال تحديث التطبيق.'),
          const SizedBox(height: 12),
          const Row(children: [
            Expanded(child: _GalleryPlaceholder(label: 'صور المصنع')),
            SizedBox(width: 10),
            Expanded(child: _GalleryPlaceholder(label: 'صور البلك')),
            SizedBox(width: 10),
            Expanded(child: _GalleryPlaceholder(label: 'الشاحنات')),
          ]),
          const SizedBox(height: 18),
          Card(child: ListTile(leading: const Icon(Icons.location_on), title: const Text(factoryLocation), subtitle: const Text('اليمن'), onTap: _openMap)),
        ],
      );
}

class AdminScreen extends StatefulWidget {
  final List<Product> initialProducts;
  const AdminScreen({super.key, required this.initialProducts});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late List<Product> _products;

  @override
  void initState() {
    super.initState();
    _products = List<Product>.from(widget.initialProducts);
  }

  Future<void> _editProduct([Product? product]) async {
    final result = await showDialog<Product>(
      context: context,
      builder: (_) => ProductEditorDialog(product: product),
    );
    if (result == null) return;
    setState(() {
      final index = _products.indexWhere((p) => p.id == result.id);
      if (index >= 0) {
        _products[index] = result;
      } else {
        _products.add(result);
      }
    });
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج؟'),
        content: Text('هل تريد حذف «${product.name}»؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirm == true) setState(() => _products.removeWhere((p) => p.id == product.id));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('إدارة المنتجات')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _editProduct(),
          icon: const Icon(Icons.add),
          label: const Text('إضافة منتج'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFFE9D5), borderRadius: BorderRadius.circular(14)),
              child: const Text(
                'تنبيه: هذه لوحة إدارة محلية تجريبية بلا تسجيل دخول. أي شخص يفتح التطبيق على الجهاز يمكنه تعديل المنتجات. البيانات محفوظة على هذا الجهاز فقط ولا تتزامن مع أجهزة العملاء.',
                style: TextStyle(height: 1.5),
              ),
            ),
            const SizedBox(height: 14),
            if (_products.isEmpty)
              const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('لا توجد منتجات بعد. اضغط «إضافة منتج».')))
            else
              ..._products.map((product) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text([
                        if (product.size.isNotEmpty) 'المقاس: ${product.size}',
                        if (product.price != null && product.price!.isNotEmpty) 'السعر: ${product.price}',
                      ].join(' • ')),
                      trailing: Wrap(spacing: 0, children: [
                        IconButton(onPressed: () => _editProduct(product), icon: const Icon(Icons.edit_outlined)),
                        IconButton(onPressed: () => _deleteProduct(product), icon: const Icon(Icons.delete_outline)),
                      ]),
                    ),
                  )),
            const SizedBox(height: 80),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              onPressed: () => Navigator.pop(context, _products),
              icon: const Icon(Icons.save),
              label: const Text('حفظ التغييرات والعودة'),
            ),
          ),
        ),
      );
}

class ProductEditorDialog extends StatefulWidget {
  final Product? product;
  const ProductEditorDialog({super.key, this.product});

  @override
  State<ProductEditorDialog> createState() => _ProductEditorDialogState();
}

class _ProductEditorDialogState extends State<ProductEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _size;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _imageUrl;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _size = TextEditingController(text: p?.size ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(text: p?.price ?? '');
    _imageUrl = TextEditingController(text: p?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _size.dispose();
    _description.dispose();
    _price.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.product == null ? 'إضافة منتج' : 'تعديل المنتج'),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'اسم المنتج *'), validator: (v) => v == null || v.trim().isEmpty ? 'اكتب اسم المنتج' : null),
                const SizedBox(height: 10),
                TextFormField(controller: _size, decoration: const InputDecoration(labelText: 'المقاس')),
                const SizedBox(height: 10),
                TextFormField(controller: _description, decoration: const InputDecoration(labelText: 'الوصف'), maxLines: 3),
                const SizedBox(height: 10),
                TextFormField(controller: _price, decoration: const InputDecoration(labelText: 'السعر (اختياري)')),
                const SizedBox(height: 10),
                TextFormField(controller: _imageUrl, decoration: const InputDecoration(labelText: 'رابط صورة المنتج (اختياري)'), keyboardType: TextInputType.url),
              ]),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              final id = widget.product?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
              Navigator.pop(
                context,
                Product(
                  id: id,
                  name: _name.text.trim(),
                  size: _size.text.trim(),
                  description: _description.text.trim(),
                  price: _price.text.trim().isEmpty ? null : _price.text.trim(),
                  imageUrl: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
                ),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          if (trailing != null) trailing!,
        ],
      );
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FeatureCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Column(children: [
            Icon(icon, size: 32, color: AlriyadhApp.orange),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ]),
        ),
      );
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ContactTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: CircleAvatar(backgroundColor: const Color(0xFFF5E6D9), child: Icon(icon, color: AlriyadhApp.cement)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
          onTap: onTap,
        ),
      );
}

class _GalleryPlaceholder extends StatelessWidget {
  final String label;
  const _GalleryPlaceholder({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        height: 95,
        decoration: BoxDecoration(color: const Color(0xFFE8E5E0), borderRadius: BorderRadius.circular(14)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.add_photo_alternate_outlined, size: 27, color: AlriyadhApp.cement),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 11)),
        ]),
      );
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: const [
            Icon(Icons.inventory_2_outlined, size: 42, color: AlriyadhApp.cement),
            SizedBox(height: 8),
            Text('لا توجد منتجات مضافة حاليًا', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('يمكن إضافة المنتجات والمقاسات والأسعار من زر إدارة المنتجات.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
          ]),
        ),
      );
}
