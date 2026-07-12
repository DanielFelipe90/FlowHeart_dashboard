import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/users_provider.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: const Text(
          'Novo Usuário',
          style: TextStyle(color: AppTheme.white, fontSize: 17),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                style: const TextStyle(color: AppTheme.white, fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Nome completo',
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppTheme.white, fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'usuario@exemplo.com',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o e-mail';
                  if (!v.contains('@')) return 'E-mail inválido';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.whiteSubtle),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              await context.read<UsersProvider>().addUser(
                    nameCtrl.text.trim(),
                    emailCtrl.text.trim(),
                  );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Usuário adicionado com sucesso')),
                );
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: const Text(
          'Remover usuário',
          style: TextStyle(color: AppTheme.white, fontSize: 17),
        ),
        content: Text(
          'Deseja remover "${user.name}" permanentemente?',
          style: const TextStyle(
              color: AppTheme.whiteSubtle, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.whiteSubtle)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<UsersProvider>().deleteUser(user.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('${user.name} removido')),
                );
              }
            },
            child: const Text(
              'Remover',
              style: TextStyle(color: AppTheme.statusOffline),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UsersProvider>();
    final users = provider.filteredUsers;

    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Usuários',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${provider.totalUsers} cadastrados · ${provider.activeUsers} ativos',
                      style: const TextStyle(
                        color: AppTheme.whiteSubtle,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _showAddUserDialog,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppTheme.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: AppTheme.white, fontSize: 14),
            onChanged: (val) =>
                context.read<UsersProvider>().setSearchQuery(val),
            decoration: InputDecoration(
              hintText: 'Buscar por nome ou e-mail...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppTheme.whiteSubtle,
                size: 18,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close,
                          color: AppTheme.whiteSubtle, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        context
                            .read<UsersProvider>()
                            .setSearchQuery('');
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Divider
        const Divider(color: AppTheme.border, height: 1),

        // Loading or list
        if (provider.isLoading)
          const Expanded(
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppTheme.white,
                  strokeWidth: 1.5,
                ),
              ),
            ),
          )
        else if (users.isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_outlined,
                      color: AppTheme.whiteDisabled, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'Nenhum usuário encontrado',
                    style: TextStyle(
                        color: AppTheme.whiteSubtle, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: users.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: AppTheme.border, height: 1),
              itemBuilder: (ctx, i) => _UserListItem(
                user: users[i],
                onDelete: () => _confirmDelete(context, users[i]),
              ),
            ),
          ),
      ],
    );
  }
}

class _UserListItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback onDelete;

  const _UserListItem({
    required this.user,
    required this.onDelete,
  });

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  String get _initials {
    final parts = user.name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return user.name.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (user.isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.statusOnline,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: AppTheme.whiteSubtle,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Desde ${_formatDate(user.createdAt)}',
                  style: const TextStyle(
                    color: AppTheme.whiteDisabled,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Delete button
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: AppTheme.whiteDisabled,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}
