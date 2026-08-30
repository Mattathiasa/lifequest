import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/attributes.dart';
import 'progression_controller.dart';

/// Skill node unlock requirements based on the design spec.
class SkillNodeRequirement {
  const SkillNodeRequirement({
    required this.attribute,
    required this.minValue,
    required this.minQuestsInCategory,
  });

  final Attribute attribute;
  final int minValue;
  final int minQuestsInCategory;
}

/// The unlock requirements for each skill branch's nodes.
const skillNodeRequirements = <String, List<SkillNodeRequirement>>{
  'Health': [
    SkillNodeRequirement(attribute: Attribute.health, minValue: 0, minQuestsInCategory: 0),
    SkillNodeRequirement(attribute: Attribute.health, minValue: 30, minQuestsInCategory: 25),
    SkillNodeRequirement(attribute: Attribute.health, minValue: 50, minQuestsInCategory: 60),
    SkillNodeRequirement(attribute: Attribute.health, minValue: 75, minQuestsInCategory: 150),
  ],
  'Knowledge': [
    SkillNodeRequirement(attribute: Attribute.intellect, minValue: 0, minQuestsInCategory: 0),
    SkillNodeRequirement(attribute: Attribute.intellect, minValue: 35, minQuestsInCategory: 30),
    SkillNodeRequirement(attribute: Attribute.intellect, minValue: 55, minQuestsInCategory: 80),
    SkillNodeRequirement(attribute: Attribute.intellect, minValue: 80, minQuestsInCategory: 200),
  ],
  'Career': [
    SkillNodeRequirement(attribute: Attribute.focus, minValue: 0, minQuestsInCategory: 0),
    SkillNodeRequirement(attribute: Attribute.focus, minValue: 30, minQuestsInCategory: 40),
    SkillNodeRequirement(attribute: Attribute.focus, minValue: 55, minQuestsInCategory: 100),
    SkillNodeRequirement(attribute: Attribute.focus, minValue: 80, minQuestsInCategory: 250),
  ],
  'Finance': [
    SkillNodeRequirement(attribute: Attribute.discipline, minValue: 0, minQuestsInCategory: 0),
    SkillNodeRequirement(attribute: Attribute.discipline, minValue: 25, minQuestsInCategory: 30),
    SkillNodeRequirement(attribute: Attribute.discipline, minValue: 50, minQuestsInCategory: 75),
    SkillNodeRequirement(attribute: Attribute.discipline, minValue: 80, minQuestsInCategory: 200),
  ],
  'Bonds': [
    SkillNodeRequirement(attribute: Attribute.social, minValue: 0, minQuestsInCategory: 0),
    SkillNodeRequirement(attribute: Attribute.social, minValue: 25, minQuestsInCategory: 25),
    SkillNodeRequirement(attribute: Attribute.social, minValue: 50, minQuestsInCategory: 70),
    SkillNodeRequirement(attribute: Attribute.social, minValue: 75, minQuestsInCategory: 160),
  ],
  'Craft': [
    SkillNodeRequirement(attribute: Attribute.creativity, minValue: 0, minQuestsInCategory: 0),
    SkillNodeRequirement(attribute: Attribute.creativity, minValue: 25, minQuestsInCategory: 28),
    SkillNodeRequirement(attribute: Attribute.creativity, minValue: 50, minQuestsInCategory: 80),
    SkillNodeRequirement(attribute: Attribute.creativity, minValue: 75, minQuestsInCategory: 180),
  ],
  'Mind': [
    SkillNodeRequirement(attribute: Attribute.discipline, minValue: 0, minQuestsInCategory: 0),
    SkillNodeRequirement(attribute: Attribute.discipline, minValue: 30, minQuestsInCategory: 30),
    SkillNodeRequirement(attribute: Attribute.discipline, minValue: 55, minQuestsInCategory: 75),
    SkillNodeRequirement(attribute: Attribute.discipline, minValue: 80, minQuestsInCategory: 180),
  ],
};

/// Maps skill branch names to the quest category they track.
const branchCategoryMap = <String, String>{
  'Health': 'health',
  'Knowledge': 'learning',
  'Career': 'productivity',
  'Finance': 'finance',
  'Bonds': 'social',
  'Craft': 'mindfulness', // Creative quests
  'Mind': 'mindfulness',
};

/// Determines the state of a skill node based on requirements and current stats.
String determineNodeState({
  required int attributeValue,
  required int questsInCategory,
  required SkillNodeRequirement requirement,
  required int previousNodeIndex,
  required List<String> previousNodeStates,
}) {
  // First node is always available (or mastered if prerequisites met)
  if (previousNodeIndex < 0) {
    if (attributeValue >= requirement.minValue && questsInCategory >= requirement.minQuestsInCategory) {
      return 'Mastered';
    }
    return 'Unlocked';
  }

  // Check if previous node is mastered or unlocked
  final prevNodeState = previousNodeStates[previousNodeIndex];
  if (prevNodeState == 'Locked') {
    return 'Locked';
  }

  // Check if this node's requirements are met
  final attributeMet = attributeValue >= requirement.minValue;
  final questsMet = questsInCategory >= requirement.minQuestsInCategory;

  if (attributeMet && questsMet) {
    // Check if this is the last unlocked node
    final allPreviousMastered = previousNodeStates.every(
      (s) => s == 'Mastered' || s == 'Unlocked',
    );
    if (allPreviousMastered) {
      // This node can be unlocked or mastered
      return 'Unlocked';
    }
  }

  // Requirements not met but previous node is unlocked
  if (prevNodeState == 'Unlocked' || prevNodeState == 'Mastered') {
    if (attributeMet && questsMet) {
      return 'Unlocked';
    }
    return 'Available';
  }

  return 'Locked';
}

/// Provider for skill node states for a given branch.
final skillNodeStatesProvider = Provider.family<List<String>, String>((ref, branch) {
  final attributes = ref.watch(attributesProvider);
  final history = ref.watch(historyProvider);

  final requirements = skillNodeRequirements[branch] ?? [];
  final states = <String>[];

  // Count quests in this branch's category
  final categoryName = branchCategoryMap[branch];
  final questsInCategory = history.where(
    (e) => e.category.name == categoryName,
  ).length;

  for (var i = 0; i < requirements.length; i++) {
    final req = requirements[i];
    final attributeValue = attributes[req.attribute];

    final state = determineNodeState(
      attributeValue: attributeValue,
      questsInCategory: questsInCategory,
      requirement: req,
      previousNodeIndex: i - 1,
      previousNodeStates: states,
    );
    states.add(state);
  }

  return states;
});
