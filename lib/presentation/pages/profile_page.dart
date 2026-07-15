import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/firestore_paths.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/usecases/profile/get_badges_usecase.dart';
import '../../domain/usecases/profile/watch_profile_usecase.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/profile/profile_bloc.dart';

/// Pantalla de perfil y gamificación (F-05).
///
/// Muestra en tiempo real: datos del usuario, puntos y nivel,
/// insignias desbloqueadas, impacto (kg reciclados y CO2 ahorrado)
/// y el botón de cerrar sesión.
class ProfilePage extends StatelessWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(
        watchProfile: sl<WatchProfileUseCase>(),
        getBadges: sl<GetBadgesUseCase>(),
      )..add(ProfileStarted(uid)),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  IconData _badgeIcon(String name) {
    switch (name) {
      case 'leaf':
        return Icons.eco;
      case 'recycle':
        return Icons.recycling;
      case 'star':
        return Icons.star;
      case 'medal':
        return Icons.military_tech;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state.status == ProfileStatus.loading || state.user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final u = state.user!;
        final initials = u.name.isNotEmpty
            ? u.name.trim().split(' ').map((e) => e[0]).take(2).join()
            : '?';

        return ListView(
          children: [
            // Cabecera verde
            Container(
              width: double.infinity,
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: Text(initials.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark)),
                ),
                const SizedBox(height: 8),
                Text(u.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(u.role.label,
                      style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w500)),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Puntos
                  Card(
                    color: const Color(0xFFFFFDE7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFFFF176))),
                    child: ListTile(
                      leading: const Icon(Icons.emoji_events,
                          color: AppColors.warning, size: 32),
                      title: Text('${u.points} puntos totales',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE65100))),
                      subtitle: Text('Nivel: ${u.level}',
                          style: const TextStyle(color: AppColors.warning)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Mis insignias',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Row(
                    children: state.badges
                        .map((b) => Expanded(child: _BadgeTile(badge: b, icon: _badgeIcon(b.iconName))))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Mi impacto',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: _StatCard(
                            value: '${u.kgRecycled.toStringAsFixed(0)} kg',
                            label: 'Reciclado')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _StatCard(
                            value:
                                '~${(u.kgRecycled * 0.2).toStringAsFixed(0)} kg',
                            label: 'CO₂ ahorrado')),
                  ]),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(AuthSignOutRequested()),
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: const Text(AppStrings.logout,
                        style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: Color(0xFFFFCDD2)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final BadgeEntity badge;
  final IconData icon;
  const _BadgeTile({required this.badge, required this.icon});

  @override
  Widget build(BuildContext context) {
    final on = badge.unlocked;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: on ? const Color(0xFFE8F5E9) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: on ? AppColors.primaryLight : AppColors.border),
          ),
          child: Icon(icon,
              color: on ? AppColors.primary : AppColors.border, size: 26),
        ),
        const SizedBox(height: 4),
        Text(badge.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textHint)),
      ]),
    );
  }
}
