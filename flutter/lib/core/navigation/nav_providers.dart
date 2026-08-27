import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which bottom-nav tab is active (0=Trail, 1=Quests, 2=Character, 3=Progress,
/// 4=Profile). Shared so flows like "Add all four" can jump tabs.
final navIndexProvider = StateProvider<int>((_) => 0);

/// Which segment the Quest board shows (0=Today, 1=Upcoming, 2=Recurring,
/// 3=Completed).
final boardTabProvider = StateProvider<int>((_) => 0);
