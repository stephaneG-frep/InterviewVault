import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'data/vault_store.dart';
import 'models/interview.dart';

const navy = Color(0xFF102A43);
const blue = Color(0xFF2563EB);
const mint = Color(0xFF18A999);

class InterviewVaultApp extends StatelessWidget {
  const InterviewVaultApp({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<VaultStore>();
    return MaterialApp(
      title: 'InterviewVault',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: settings.seedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        cardTheme: const CardThemeData(elevation: 0, color: Colors.white),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: settings.seedColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        cardTheme: const CardThemeData(elevation: 0),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  static const destinations = [
    NavigationDestination(
      icon: Icon(Icons.space_dashboard_outlined),
      selectedIcon: Icon(Icons.space_dashboard),
      label: 'Accueil',
    ),
    NavigationDestination(
      icon: Icon(Icons.work_outline),
      selectedIcon: Icon(Icons.work),
      label: 'Entretiens',
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_stories_outlined),
      selectedIcon: Icon(Icons.auto_stories),
      label: 'Préparation',
    ),
    NavigationDestination(
      icon: Icon(Icons.mic_none),
      selectedIcon: Icon(Icons.mic),
      label: 'Simulation',
    ),
    NavigationDestination(
      icon: Icon(Icons.insights_outlined),
      selectedIcon: Icon(Icons.insights),
      label: 'Analyses',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final pages = [
      const DashboardPage(),
      const InterviewsPage(),
      const PreparationPage(),
      const SimulationPage(),
      const AnalyticsPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_outline, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'InterviewVault',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Thèmes',
            onPressed: () => showThemeApplet(context),
            icon: const Icon(Icons.palette_outlined),
          ),
          IconButton(
            tooltip: 'Aide',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const HelpPage())),
            icon: const Icon(Icons.help_outline),
          ),
          IconButton(
            tooltip: 'Nouvel entretien',
            onPressed: () => openInterviewForm(context),
            icon: const Icon(Icons.add_circle_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              backgroundColor: Theme.of(context).colorScheme.surface,
              extended: MediaQuery.sizeOf(context).width > 1150,
              selectedIndex: index,
              onDestinationSelected: (v) => setState(() => index = v),
              destinations: destinations
                  .map(
                    (e) => NavigationRailDestination(
                      icon: e.icon,
                      selectedIcon: e.selectedIcon,
                      label: Text(e.label),
                    ),
                  )
                  .toList(),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(key: ValueKey(index), child: pages[index]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (v) => setState(() => index = v),
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: destinations,
            ),
      floatingActionButton: index == 1
          ? FloatingActionButton.extended(
              onPressed: () => openInterviewForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            )
          : null,
    );
  }
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
  });
  final String title, subtitle;
  final Widget child;
  final Widget? action;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1250),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                ?action,
              ],
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    ),
  );
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final list = context.watch<VaultStore>().interviews;
    final now = DateTime.now();
    final upcoming =
        list
            .where(
              (e) => e.date.isAfter(now) && e.status != InterviewStatus.annule,
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    final accepted = list
        .where((e) => e.status == InterviewStatus.accepte)
        .length;
    final decided = list
        .where(
          (e) =>
              e.status == InterviewStatus.accepte ||
              e.status == InterviewStatus.refuse,
        )
        .length;
    return PageFrame(
      title: 'Bonjour 👋',
      subtitle: 'Votre préparation, vos progrès, vos opportunités.',
      action: FilledButton.icon(
        onPressed: () => openInterviewForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouvel entretien'),
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final width = c.maxWidth;
              final n = width > 900
                  ? 4
                  : width > 520
                  ? 2
                  : 1;
              return GridView.count(
                crossAxisCount: n,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisExtent: 124,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  MetricCard(
                    icon: Icons.work_outline,
                    label: 'Total entretiens',
                    value: '${list.length}',
                    color: blue,
                  ),
                  MetricCard(
                    icon: Icons.event_available,
                    label: 'À venir',
                    value: '${upcoming.length}',
                    color: mint,
                  ),
                  MetricCard(
                    icon: Icons.emoji_events_outlined,
                    label: 'Acceptés',
                    value: '$accepted',
                    color: const Color(0xFFF59E0B),
                  ),
                  MetricCard(
                    icon: Icons.trending_up,
                    label: 'Taux de réussite',
                    value: decided == 0
                        ? '—'
                        : '${(accepted * 100 / decided).round()} %',
                    color: const Color(0xFF8B5CF6),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, c) => c.maxWidth > 780
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: UpcomingCard(items: upcoming)),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: ProgressCard(items: list)),
                    ],
                  )
                : Column(
                    children: [
                      UpcomingCard(items: upcoming),
                      const SizedBox(height: 16),
                      ProgressCard(items: list),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class UpcomingCard extends StatelessWidget {
  const UpcomingCard({super.key, required this.items});
  final List<Interview> items;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Prochains entretiens', Icons.upcoming_outlined),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const EmptyState(
              icon: Icons.event_busy,
              title: 'Aucun entretien à venir',
              subtitle: 'Ajoutez votre prochaine opportunité pour commencer.',
            )
          else
            ...items.take(4).map((e) => InterviewTile(item: e)),
        ],
      ),
    ),
  );
}

class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key, required this.items});
  final List<Interview> items;
  @override
  Widget build(BuildContext context) {
    final months = List.generate(6, (i) {
      final d = DateTime(DateTime.now().year, DateTime.now().month - 5 + i);
      return MapEntry(
        DateFormat.MMM('fr_FR').format(d),
        items
            .where((e) => e.date.year == d.year && e.date.month == d.month)
            .length,
      );
    });
    final maxV = max(1, months.map((e) => e.value).fold(0, max));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Progression sur 6 mois', Icons.bar_chart),
            const SizedBox(height: 24),
            SizedBox(
              height: 170,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: months
                    .map(
                      (e) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${e.value}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 18 + 105 * e.value / maxV,
                                decoration: BoxDecoration(
                                  color: blue.withValues(alpha: .75),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(7),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(e.key),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InterviewsPage extends StatefulWidget {
  const InterviewsPage({super.key});
  @override
  State<InterviewsPage> createState() => _InterviewsPageState();
}

class _InterviewsPageState extends State<InterviewsPage> {
  String query = '';
  InterviewStatus? filter;
  @override
  Widget build(BuildContext context) {
    var items = context.watch<VaultStore>().interviews.where((e) {
      final q = query.toLowerCase();
      return (e.company.toLowerCase().contains(q) ||
              e.position.toLowerCase().contains(q) ||
              e.recruiter.toLowerCase().contains(q) ||
              e.notes.toLowerCase().contains(q)) &&
          (filter == null || e.status == filter);
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
    return PageFrame(
      title: 'Entretiens',
      subtitle: 'Centralisez chaque étape de votre parcours.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => query = v),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Entreprise, poste, recruteur, notes…',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<InterviewStatus?>(
                tooltip: 'Filtrer',
                initialValue: filter,
                onSelected: (v) => setState(() => filter = v),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: null,
                    child: Text('Tous les statuts'),
                  ),
                  ...InterviewStatus.values.map(
                    (e) => PopupMenuItem(value: e, child: Text(e.label)),
                  ),
                ],
                child: Chip(
                  avatar: const Icon(Icons.filter_list, size: 18),
                  label: Text(filter?.label ?? 'Tous'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (items.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: EmptyState(
                  icon: Icons.work_off_outlined,
                  title: 'Aucun résultat',
                  subtitle: 'Créez un entretien ou modifiez votre recherche.',
                ),
              ),
            )
          else
            ...items.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InterviewTile(item: e, expanded: true),
              ),
            ),
        ],
      ),
    );
  }
}

class InterviewTile extends StatelessWidget {
  const InterviewTile({super.key, required this.item, this.expanded = false});
  final Interview item;
  final bool expanded;
  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEE d MMM · HH:mm', 'fr_FR').format(item.date);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => openInterviewForm(context, item: item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: blue.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.company.isEmpty ? '?' : item.company[0].toUpperCase(),
                  style: const TextStyle(
                    color: blue,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.position,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${item.company}  •  $date',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    if (expanded)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${item.type.label} · ${item.durationMinutes} min · Priorité ${item.priority.label.toLowerCase()}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              StatusChip(item.status),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final InterviewStatus status;
  @override
  Widget build(BuildContext context) {
    final c = switch (status) {
      InterviewStatus.accepte => mint,
      InterviewStatus.refuse => Colors.red,
      InterviewStatus.annule => Colors.grey,
      InterviewStatus.confirme => blue,
      _ => const Color(0xFFF59E0B),
    };
    return Chip(
      label: Text(status.label),
      labelStyle: TextStyle(color: c, fontWeight: FontWeight.w600),
      backgroundColor: c.withValues(alpha: .1),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

class PreparationPage extends StatelessWidget {
  const PreparationPage({super.key});
  @override
  Widget build(BuildContext context) {
    final cards = context.watch<VaultStore>().preparationCards;
    return PageFrame(
      title: 'Préparation',
      subtitle: 'Construisez des réponses claires, authentiques et mémorables.',
      action: OutlinedButton.icon(
        onPressed: () => showCardDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle fiche'),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final n = c.maxWidth > 900
              ? 3
              : c.maxWidth > 560
              ? 2
              : 1;
          return GridView.count(
            crossAxisCount: n,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 260,
            children: cards
                .map(
                  (card) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Chip(
                            label: Text(card['category'] as String),
                            side: BorderSide.none,
                            backgroundColor: blue.withValues(alpha: .08),
                          ),
                          const Spacer(),
                          Text(
                            card['title'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            card['content'] as String,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          const Row(
                            children: [
                              Icon(Icons.edit_note, size: 18, color: blue),
                              SizedBox(width: 5),
                              Text(
                                'Fiche locale',
                                style: TextStyle(color: blue),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class SimulationPage extends StatefulWidget {
  const SimulationPage({super.key});
  @override
  State<SimulationPage> createState() => _SimulationPageState();
}

class _SimulationPageState extends State<SimulationPage> {
  static const questions = [
    'Parlez-moi de vous.',
    'Pourquoi souhaitez-vous rejoindre notre entreprise ?',
    'Décrivez une situation où vous avez résolu un conflit.',
    'Quelle réalisation vous rend le plus fier ?',
    'Comment priorisez-vous lorsque tout semble urgent ?',
    'Parlez-moi d’un échec et de ce que vous en avez appris.',
  ];
  String? question;
  int seconds = 0;
  Timer? timer;
  bool running = false;
  int score = 3;
  void start() {
    timer?.cancel();
    setState(() {
      question = questions[Random().nextInt(questions.length)];
      seconds = 0;
      running = true;
    });
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => seconds++),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<VaultStore>().simulations;
    return PageFrame(
      title: 'Simulation',
      subtitle: 'Entraînez-vous à voix haute, mesurez et progressez.',
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: blue.withValues(alpha: .1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic, color: blue, size: 30),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    question ?? 'Prêt pour une question aléatoire ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 38,
                      fontFeatures: [FontFeature.tabularFigures()],
                      color: blue,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (!running)
                    FilledButton.icon(
                      onPressed: start,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(
                        question == null ? 'Commencer' : 'Question suivante',
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: start,
                          icon: const Icon(Icons.shuffle),
                          label: const Text('Changer'),
                        ),
                        const SizedBox(width: 10),
                        FilledButton.icon(
                          onPressed: () {
                            timer?.cancel();
                            setState(() => running = false);
                            showScoreDialog(context, seconds, (v) {
                              setState(() => score = v);
                            });
                          },
                          icon: const Icon(Icons.stop),
                          label: const Text('Terminer'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Historique',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 10),
          if (history.isEmpty)
            const EmptyState(
              icon: Icons.history,
              title: 'Pas encore de simulation',
              subtitle: 'Votre score et votre durée apparaîtront ici.',
            )
          else
            ...history
                .take(8)
                .map(
                  (h) => Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${h['score']}/5')),
                      title: Text(h['category'] as String),
                      subtitle: Text(
                        DateFormat(
                          'd MMM yyyy · HH:mm',
                          'fr_FR',
                        ).format(DateTime.parse(h['date'] as String)),
                      ),
                      trailing: Text('${h['seconds']} s'),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<VaultStore>();
    final l = s.interviews;
    final done = l
        .where(
          (e) => [
            InterviewStatus.realise,
            InterviewStatus.accepte,
            InterviewStatus.refuse,
          ].contains(e.status),
        )
        .toList();
    final avg = done.isEmpty
        ? 0
        : done.map((e) => e.durationMinutes).reduce((a, b) => a + b) ~/
              done.length;
    final companies = l
        .map((e) => e.company.toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet()
        .length;
    return PageFrame(
      title: 'Analyses',
      subtitle: 'Transformez chaque expérience en progrès concret.',
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 270,
                height: 124,
                child: MetricCard(
                  icon: Icons.business,
                  label: 'Entreprises rencontrées',
                  value: '$companies',
                  color: blue,
                ),
              ),
              SizedBox(
                width: 270,
                height: 124,
                child: MetricCard(
                  icon: Icons.timer_outlined,
                  label: 'Durée moyenne',
                  value: '$avg min',
                  color: mint,
                ),
              ),
              SizedBox(
                width: 270,
                height: 124,
                child: MetricCard(
                  icon: Icons.psychology_alt_outlined,
                  label: 'Simulations',
                  value: '${s.simulations.length}',
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Bilan des entretiens', Icons.donut_large),
                  const SizedBox(height: 18),
                  ...InterviewStatus.values.map((status) {
                    final n = l.where((e) => e.status == status).length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          SizedBox(width: 90, child: Text(status.label)),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: l.isEmpty ? 0 : n / l.length,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 25,
                            child: Text('$n', textAlign: TextAlign.end),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    'Axes d’amélioration',
                    Icons.lightbulb_outline,
                  ),
                  const SizedBox(height: 12),
                  if (done
                      .where((e) => e.improvements.trim().isNotEmpty)
                      .isEmpty)
                    const Text(
                      'Complétez le bilan de vos entretiens pour faire émerger vos tendances.',
                      style: TextStyle(color: Colors.black54),
                    )
                  else
                    ...done
                        .where((e) => e.improvements.trim().isNotEmpty)
                        .map(
                          (e) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.arrow_circle_up_outlined,
                              color: mint,
                            ),
                            title: Text(e.improvements),
                            subtitle: Text('${e.position} · ${e.company}'),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, this.icon, {super.key});
  final String text;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: blue),
      const SizedBox(width: 9),
      Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ],
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Icon(icon, size: 42, color: Colors.black26),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black45),
        ),
      ],
    ),
  );
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const _steps = [
    (
      Icons.add_circle_outline,
      'Ajoutez un entretien',
      'Renseignez le poste, l’entreprise, la date et le type de rendez-vous.',
    ),
    (
      Icons.checklist,
      'Préparez-vous',
      'Complétez la checklist et créez vos fiches de pitch ou de réponses STAR.',
    ),
    (
      Icons.mic_none,
      'Entraînez-vous',
      'Lancez une simulation, répondez à voix haute puis attribuez-vous un score.',
    ),
    (
      Icons.insights_outlined,
      'Analysez vos progrès',
      'Après l’entretien, notez les points positifs et les axes d’amélioration.',
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Aide et prise en main')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 42,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 18),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenue dans InterviewVault',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Toutes vos données restent sur cet appareil. Aucun compte et aucune connexion ne sont nécessaires.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Bien démarrer',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              ..._steps.indexed.map(
                (entry) => Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Icon(entry.$2.$1),
                    ),
                    title: Text(
                      '${entry.$1 + 1}. ${entry.$2.$2}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(entry.$2.$3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Questions fréquentes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Card(
                child: Column(
                  children: [
                    ExpansionTile(
                      title: Text('Où sont enregistrées mes données ?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 18),
                          child: Text(
                            'Dans une base Hive locale propre à l’application. Rien n’est envoyé vers un serveur.',
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 1),
                    ExpansionTile(
                      title: Text('Comment modifier un entretien ?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 18),
                          child: Text(
                            'Ouvrez la section Entretiens puis touchez la carte concernée. Tous ses onglets redeviennent modifiables.',
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 1),
                    ExpansionTile(
                      title: Text('Comment changer l’apparence ?'),
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 18),
                          child: Text(
                            'Utilisez l’icône palette dans la barre supérieure pour choisir le mode et la couleur du thème.',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'InterviewVault · Version 1.0 · 100 % local',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showThemeApplet(BuildContext context) async {
  const colors = [
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFF0F9D8A),
    Color(0xFFE05A33),
    Color(0xFFBE185D),
    Color(0xFF455A64),
  ];
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => Consumer<VaultStore>(
      builder: (context, settings, _) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Personnaliser le thème',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Choisissez l’apparence qui vous convient.'),
                  const SizedBox(height: 24),
                  const Text(
                    'Mode d’affichage',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.settings_suggest_outlined),
                        label: Text('Système'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Clair'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Sombre'),
                      ),
                    ],
                    selected: {settings.themeMode},
                    showSelectedIcon: false,
                    onSelectionChanged: (value) =>
                        settings.setThemeMode(value.first),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Couleur principale',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: colors
                        .map(
                          (color) => Semantics(
                            label: 'Choisir cette couleur',
                            button: true,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => settings.setSeedColor(color),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: settings.seedColor == color
                                      ? Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          width: 3,
                                        )
                                      : null,
                                ),
                                child: settings.seedColor == color
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> showCardDialog(BuildContext context) async {
  final title = TextEditingController(),
      category = TextEditingController(text: 'Personnelle'),
      content = TextEditingController();
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Nouvelle fiche'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: category,
              decoration: const InputDecoration(labelText: 'Catégorie'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: content,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Contenu'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            if (title.text.trim().isNotEmpty) {
              context.read<VaultStore>().addCard(
                title.text.trim(),
                category.text.trim(),
                content.text.trim(),
              );
              Navigator.pop(ctx);
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    ),
  );
}

Future<void> showScoreDialog(
  BuildContext context,
  int seconds,
  ValueChanged<int> onScore,
) async {
  int score = 3;
  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: const Text('Votre auto-évaluation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Comment jugez-vous votre réponse ?'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => IconButton(
                  onPressed: () => setLocal(() => score = i + 1),
                  icon: Icon(
                    i < score ? Icons.star : Icons.star_border,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              context.read<VaultStore>().addSimulation(
                score,
                seconds,
                'Question aléatoire',
              );
              onScore(score);
              Navigator.pop(ctx);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    ),
  );
}

Future<void> openInterviewForm(BuildContext context, {Interview? item}) async {
  await Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => InterviewFormPage(item: item)));
}

class InterviewFormPage extends StatefulWidget {
  const InterviewFormPage({super.key, this.item});
  final Interview? item;
  @override
  State<InterviewFormPage> createState() => _InterviewFormPageState();
}

class _InterviewFormPageState extends State<InterviewFormPage> {
  final keyForm = GlobalKey<FormState>();
  late Interview draft;
  late final TextEditingController position,
      company,
      recruiter,
      email,
      phone,
      address,
      video,
      salary,
      description,
      notes,
      positives,
      improvements;
  int tab = 0;
  @override
  void initState() {
    super.initState();
    draft =
        widget.item ??
        Interview(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          position: '',
          company: '',
          date: DateTime.now().add(const Duration(days: 1)),
        );
    position = TextEditingController(text: draft.position);
    company = TextEditingController(text: draft.company);
    recruiter = TextEditingController(text: draft.recruiter);
    email = TextEditingController(text: draft.email);
    phone = TextEditingController(text: draft.phone);
    address = TextEditingController(text: draft.address);
    video = TextEditingController(text: draft.videoLink);
    salary = TextEditingController(text: draft.salary);
    description = TextEditingController(text: draft.description);
    notes = TextEditingController(text: draft.notes);
    positives = TextEditingController(text: draft.positives);
    improvements = TextEditingController(text: draft.improvements);
  }

  void sync() {
    draft.position = position.text.trim();
    draft.company = company.text.trim();
    draft.recruiter = recruiter.text.trim();
    draft.email = email.text.trim();
    draft.phone = phone.text.trim();
    draft.address = address.text.trim();
    draft.videoLink = video.text.trim();
    draft.salary = salary.text.trim();
    draft.description = description.text.trim();
    draft.notes = notes.text.trim();
    draft.positives = positives.text.trim();
    draft.improvements = improvements.text.trim();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.item == null ? 'Nouvel entretien' : 'Modifier l’entretien',
      ),
      actions: [
        if (widget.item != null)
          IconButton(
            onPressed: () {
              context.read<VaultStore>().deleteInterview(draft.id);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline),
          ),
        const SizedBox(width: 8),
      ],
    ),
    body: Form(
      key: keyForm,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['Informations', 'Préparation', 'Bilan & notes']
                    .asMap()
                    .entries
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.all(5),
                        child: ChoiceChip(
                          selected: tab == e.key,
                          onSelected: (_) => setState(() => tab = e.key),
                          label: Text(e.value),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: [infoTab(), checklistTab(), reviewTab()][tab],
                ),
              ),
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () {
                    if (keyForm.currentState!.validate()) {
                      sync();
                      context.read<VaultStore>().saveInterview(draft);
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Enregistrer'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  Widget infoTab() => Column(
    children: [
      RowOrColumn(
        children: [
          field(position, 'Intitulé du poste *', required: true),
          field(company, 'Entreprise *', required: true),
        ],
      ),
      const SizedBox(height: 14),
      RowOrColumn(
        children: [field(recruiter, 'Nom du recruteur'), field(email, 'Email')],
      ),
      const SizedBox(height: 14),
      RowOrColumn(
        children: [field(phone, 'Téléphone'), field(address, 'Adresse')],
      ),
      const SizedBox(height: 14),
      RowOrColumn(
        children: [
          dateField(),
          DropdownButtonFormField<InterviewType>(
            initialValue: draft.type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: InterviewType.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                .toList(),
            onChanged: (v) => draft.type = v!,
          ),
        ],
      ),
      const SizedBox(height: 14),
      RowOrColumn(
        children: [
          DropdownButtonFormField<InterviewStatus>(
            initialValue: draft.status,
            decoration: const InputDecoration(labelText: 'Statut'),
            items: InterviewStatus.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                .toList(),
            onChanged: (v) => draft.status = v!,
          ),
          DropdownButtonFormField<InterviewPriority>(
            initialValue: draft.priority,
            decoration: const InputDecoration(labelText: 'Priorité'),
            items: InterviewPriority.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                .toList(),
            onChanged: (v) => draft.priority = v!,
          ),
        ],
      ),
      const SizedBox(height: 14),
      RowOrColumn(
        children: [
          field(video, 'Lien de visioconférence'),
          field(salary, 'Salaire proposé'),
        ],
      ),
      const SizedBox(height: 14),
      field(description, 'Description du poste', lines: 4),
    ],
  );
  Widget checklistTab() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionTitle('Checklist avant entretien', Icons.checklist),
      const SizedBox(height: 10),
      ...draft.checklist.map(
        (e) => CheckboxListTile(
          value: draft.checkedItems.contains(e),
          onChanged: (v) => setState(() {
            v! ? draft.checkedItems.add(e) : draft.checkedItems.remove(e);
          }),
          title: Text(e),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
      const SizedBox(height: 20),
      field(notes, 'Notes personnelles et questions à poser', lines: 7),
    ],
  );
  Widget reviewTab() => Column(
    children: [
      field(positives, 'Ce qui s’est bien passé', lines: 4),
      const SizedBox(height: 14),
      field(
        improvements,
        'Points à améliorer / questions difficiles',
        lines: 4,
      ),
      const SizedBox(height: 14),
      field(notes, 'Notes libres et résultat', lines: 6),
      const SizedBox(height: 18),
      Row(
        children: [
          const Text('Ressenti', style: TextStyle(fontWeight: FontWeight.w700)),
          const Spacer(),
          ...List.generate(
            5,
            (i) => IconButton(
              onPressed: () => setState(() => draft.feeling = i + 1),
              icon: Icon(
                i < draft.feeling
                    ? Icons.sentiment_satisfied
                    : Icons.sentiment_neutral_outlined,
                color: i < draft.feeling ? mint : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    ],
  );
  Widget field(
    TextEditingController c,
    String label, {
    int lines = 1,
    bool required = false,
  }) => TextFormField(
    controller: c,
    maxLines: lines,
    validator: required
        ? ((v) => v == null || v.trim().isEmpty ? 'Champ requis' : null)
        : null,
    decoration: InputDecoration(labelText: label),
  );
  Widget dateField() => InkWell(
    onTap: () async {
      final d = await showDatePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2040),
        initialDate: draft.date,
      );
      if (d == null) return;
      if (!mounted) return;
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(draft.date),
      );
      setState(
        () => draft.date = DateTime(
          d.year,
          d.month,
          d.day,
          t?.hour ?? draft.date.hour,
          t?.minute ?? draft.date.minute,
        ),
      );
    },
    child: InputDecorator(
      decoration: const InputDecoration(labelText: 'Date et heure'),
      child: Text(
        DateFormat('EEEE d MMMM yyyy · HH:mm', 'fr_FR').format(draft.date),
      ),
    ),
  );
}

class RowOrColumn extends StatelessWidget {
  const RowOrColumn({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => c.maxWidth > 600
        ? Row(
            children: [
              Expanded(child: children[0]),
              const SizedBox(width: 14),
              Expanded(child: children[1]),
            ],
          )
        : Column(
            children: [children[0], const SizedBox(height: 14), children[1]],
          ),
  );
}
