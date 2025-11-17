import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemapedia/presentation/providers/auth/auth_provider.dart';

class CustomAppbar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Text('Cinemapedia', style: titleStyle),
              Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.search_outlined),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final authState = ref.watch(authStateProvider);
                  return authState.when(
                    data: (user) {
                      if (user != null) {
                        return IconButton(
                          onPressed: () {
                            ref.read(authProvider.notifier).signOut();
                          },
                          icon: Icon(Icons.logout_outlined),
                        );
                      }
                      return SizedBox.shrink();
                    },
                    loading: () => CircularProgressIndicator(),
                    error: (error, stack) => SizedBox.shrink(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}