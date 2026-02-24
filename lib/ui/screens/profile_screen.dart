import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../state/auth_state.dart';
import '../../state/providers.dart';
import '../../utils/helpers.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  UserRole _rol = UserRole.agricultor;
  bool _editing = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      _nombreCtrl.text = user.nombre;
      _regionCtrl.text = user.region;
      _rol = user.rol;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _regionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(UserModel current) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final updated = current.copyWith(
        nombre: _nombreCtrl.text.trim(),
        rol: _rol,
        region: _regionCtrl.text.trim().isEmpty
            ? 'Los Mochis'
            : _regionCtrl.text.trim(),
      );
      await ref.read(currentUserProvider.notifier).update(updated);
      if (mounted) {
        context.showSnackBar('Perfil actualizado');
        setState(() => _editing = false);
      }
    } catch (e) {
      if (mounted) context.showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar sesión?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cerrar sesión')),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authServiceProvider).signOut();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            ErrorStateWidget(message: 'Error cargando perfil: ${e.toString()}'),
        data: (user) {
          if (user == null) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => context.go('/login'),
            );
            return const SizedBox.shrink();
          }
          return LoadingOverlay(
            isLoading: _loading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFF2E7D32),
                        child: Text(
                          user.nombre.isNotEmpty
                              ? user.nombre[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontSize: 40, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(child: Text(user.email)),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nombreCtrl,
                      enabled: _editing,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Campo requerido'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _regionCtrl,
                      enabled: _editing,
                      decoration: const InputDecoration(
                        labelText: 'Región',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<UserRole>(
                      value: _rol,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      items: UserRole.values
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text(r == UserRole.agricultor
                                    ? 'Agricultor'
                                    : 'Ingeniero Agrónomo'),
                              ))
                          .toList(),
                      onChanged: _editing
                          ? (v) {
                              if (v != null) setState(() => _rol = v);
                            }
                          : null,
                    ),
                    if (_editing) ...[
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _save(user),
                        child: const Text('Guardar cambios'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          _nombreCtrl.text = user.nombre;
                          _regionCtrl.text = user.region;
                          _rol = user.rol;
                          setState(() => _editing = false);
                        },
                        child: const Text('Cancelar'),
                      ),
                    ],
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Cerrar sesión',
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
