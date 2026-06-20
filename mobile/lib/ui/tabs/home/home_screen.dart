import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AuraTalk'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.photo_camera_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: const [
          _StoriesSection(),
          Gap(14),
          _PostsSection(),
          Gap(14),
          _NavigationSection(),
          Gap(14),
          _QuickActionsSection(),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, this.trailing, required this.child});
  final String title;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                ...? (trailing == null ? null : [trailing!]),
              ],
            ),
            const Gap(12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StoriesSection extends StatelessWidget {
  const _StoriesSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Stories',
      trailing: TextButton(onPressed: () {}, child: const Text('See all')),
      child: SizedBox(
        height: 92,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 6,
            separatorBuilder: (_, index) => const Gap(12),
          itemBuilder: (context, i) {
            if (i == 0) {
              return const _StoryAvatar(label: 'Your Story', isAdd: true, online: false);
            }
            return _StoryAvatar(
              label: ['Aarav', 'Priya', 'Rohan', 'Ananya', 'Kabir'][i - 1],
              online: i.isEven,
            );
          },
        ),
      ),
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  const _StoryAvatar({required this.label, required this.online, this.isAdd = false});
  final String label;
  final bool online;
  final bool isAdd;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primary.withValues(alpha: 0.35), width: 2),
                ),
                child: CircleAvatar(
                  backgroundColor: primary.withValues(alpha: 0.12),
                  child: isAdd ? Icon(Icons.add, color: primary, size: 28) : const Icon(Icons.person, color: Colors.white),
                ),
              ),
              if (online)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const Gap(8),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _PostsSection extends StatelessWidget {
  const _PostsSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Posts',
      child: Column(
        children: const [
          _PostCard(),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF9FAFF),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Aarav Mehta', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const Gap(2),
                      Text('2h ago · 🌍', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF6B7280))),
                    ],
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
              ],
            ),
            const Gap(12),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFE7EAF7),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text('Image', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: const Color(0xFF6B7280))),
            ),
            const Gap(10),
            Row(
              children: [
                _PostIcon(icon: Icons.favorite_border, label: '128'),
                const Gap(18),
                _PostIcon(icon: Icons.mode_comment_outlined, label: '24'),
                const Gap(18),
                _PostIcon(icon: Icons.send_outlined, label: '12'),
                const Spacer(),
                IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PostIcon extends StatelessWidget {
  const _PostIcon({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const Gap(6),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF6B7280))),
      ],
    );
  }
}

class _NavigationSection extends StatelessWidget {
  const _NavigationSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Navigation',
      child: Column(
        children: const [
          _NavRow(icon: Icons.explore_outlined, title: 'Explore Zones', subtitle: 'Discover communities and topics'),
          Gap(10),
          _NavRow(icon: Icons.groups_outlined, title: 'My Zones', subtitle: 'Your communities and groups'),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primary),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Gap(2),
                Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF6B7280))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF9AA3B2)),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Quick Actions',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _QuickAction(icon: Icons.chat_bubble_outline, title: 'New Chat', subtitle: 'Message anyone'),
          _QuickAction(icon: Icons.group_add_outlined, title: 'New Zone', subtitle: 'Create a zone'),
          _QuickAction(icon: Icons.call_outlined, title: 'Voice Call', subtitle: 'Start a call'),
          _QuickAction(icon: Icons.person_add_alt_1_outlined, title: 'Add Contact', subtitle: 'Invite friends'),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primary),
          ),
          const Gap(8),
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
          const Gap(2),
          Text(subtitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

