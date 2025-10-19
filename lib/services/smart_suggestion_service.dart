import '../models/pet.dart';
import '../models/smart_suggestion.dart';
import 'pet_care_knowledge_base.dart';
import '../database/db_helper.dart';
import '../database/pet_health_db_helper.dart';

/// Smart AI-powered suggestion service
/// Analyzes pet data and generates contextual recommendations
class SmartSuggestionService {
  
  /// Generate all suggestions for a pet
  static Future<List<SmartSuggestion>> generateSuggestionsForPet(Pet pet) async {
    final List<SmartSuggestion> suggestions = [];
    
    // Generate different types of suggestions
    suggestions.addAll(await _generateFeedingSuggestions(pet));
    suggestions.addAll(await _generateSeasonalSuggestions(pet));
    suggestions.addAll(await _generateVeterinarySuggestions(pet));
    suggestions.addAll(_generateWeatherSuggestions(pet));
    suggestions.addAll(_generateMilestoneSuggestions(pet));
    suggestions.addAll(_generateExerciseSuggestions(pet));
    
    // Sort by priority
    suggestions.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    
    return suggestions;
  }

  /// Generate suggestions for all pets
  static Future<List<SmartSuggestion>> generateAllSuggestions() async {
    final pets = await DBHelper.getPets();
    final List<SmartSuggestion> allSuggestions = [];
    
    for (final pet in pets) {
      final petSuggestions = await generateSuggestionsForPet(pet);
      allSuggestions.addAll(petSuggestions);
    }
    
    // Add general (non-pet-specific) suggestions
    allSuggestions.addAll(_generateGeneralSuggestions());
    
    return allSuggestions;
  }

  /// Generate feeding time suggestions based on pet type and age
  static Future<List<SmartSuggestion>> _generateFeedingSuggestions(Pet pet) async {
    final List<SmartSuggestion> suggestions = [];
    final species = pet.species ?? 'Unknown';
    final ageInMonths = pet.age * 12; // Convert years to months
    
    final feedingSchedule = PetCareKnowledgeBase.getFeedingSchedule(species, ageInMonths);
    
    // Only suggest if feeding schedule is appropriate
    if (feedingSchedule.isNotEmpty) {
      final schedule = feedingSchedule.first;
      suggestions.add(SmartSuggestion(
        type: SuggestionType.feeding,
        title: 'Optimal Feeding Schedule for ${pet.name}',
        description: 'Based on ${pet.name}\'s age and species, we recommend ${schedule.schedule}',
        reason: schedule.reason,
        priority: SuggestionPriority.medium,
        source: SuggestionSource.bestPractices,
        petId: pet.id,
        actionType: 'create_feeding_reminders',
        actionData: {
          'schedule': feedingSchedule.map((f) => f.time).join(','),
          'frequency': schedule.schedule,
        },
      ));
    }
    
    return suggestions;
  }

  /// Generate seasonal care suggestions
  static Future<List<SmartSuggestion>> _generateSeasonalSuggestions(Pet pet) async {
    final List<SmartSuggestion> suggestions = [];
    final season = PetCareKnowledgeBase.getCurrentSeason();
    final species = pet.species ?? 'Unknown';
    
    final seasonalCare = PetCareKnowledgeBase.getSeasonalRecommendations(season, species);
    
    for (final care in seasonalCare) {
      final priority = care.priority == 'urgent' 
          ? SuggestionPriority.urgent 
          : care.priority == 'high'
              ? SuggestionPriority.high
              : SuggestionPriority.medium;
              
      suggestions.add(SmartSuggestion(
        type: SuggestionType.seasonal,
        title: '${care.title} for ${pet.name}',
        description: care.description,
        reason: care.reason,
        priority: priority,
        source: SuggestionSource.seasonal,
        petId: pet.id,
        expiresAt: _getSeasonEndDate(season),
        actionType: 'create_reminder',
        actionData: {
          'title': care.title,
          'category': 'health',
        },
      ));
    }
    
    return suggestions;
  }

  /// Generate veterinary visit suggestions
  static Future<List<SmartSuggestion>> _generateVeterinarySuggestions(Pet pet) async {
    final List<SmartSuggestion> suggestions = [];
    final ageInMonths = pet.age * 12;
    
    // Check vaccination schedule
    final vaccinations = PetCareKnowledgeBase.getVaccinationSchedule(
      pet.species ?? 'Unknown', 
      ageInMonths,
    );
    
    for (final vaccine in vaccinations) {
      if (vaccine.isUrgent) {
        suggestions.add(SmartSuggestion(
          type: SuggestionType.veterinary,
          title: '${vaccine.vaccineName} Due for ${pet.name}',
          description: 'Recommended timing: ${vaccine.timing}',
          reason: 'Essential for ${pet.name}\'s health protection',
          priority: SuggestionPriority.high,
          source: SuggestionSource.veterinarySchedule,
          petId: pet.id,
          actionType: 'schedule_vet_visit',
          actionData: {
            'reason': vaccine.vaccineName,
            'type': 'vaccination',
          },
        ));
      }
    }
    
    // Check age-based milestones
    final milestones = PetCareKnowledgeBase.getAgeMilestones(
      pet.species ?? 'Unknown',
      ageInMonths,
    );
    
    for (final milestone in milestones) {
      suggestions.add(SmartSuggestion(
        type: SuggestionType.milestone,
        title: milestone.title,
        description: milestone.description,
        reason: 'Age-appropriate care for ${pet.name} (${pet.age} years old)',
        priority: SuggestionPriority.high,
        source: SuggestionSource.ageBasedMilestone,
        petId: pet.id,
        actionType: 'create_reminder',
        actionData: {
          'title': milestone.title,
          'category': 'veterinary',
        },
      ));
    }
    
    // Check last vet visit from health records
    try {
      final healthRecords = await PetHealthDBHelper.getMedicalRecords(pet.id!);
      final lastVetVisit = healthRecords.isNotEmpty 
          ? healthRecords.first.visitDate 
          : null;
      
      final hasMedicalConditions = (await PetHealthDBHelper.getConditions(pet.id!)).isNotEmpty;
      
      final recommendation = PetCareKnowledgeBase.getVetVisitRecommendation(
        lastVetVisit,
        ageInMonths,
        hasMedicalConditions,
      );
      
      if (recommendation.contains('due') || recommendation.contains('Overdue')) {
        suggestions.add(SmartSuggestion(
          type: SuggestionType.veterinary,
          title: 'Vet Check-up Recommended for ${pet.name}',
          description: recommendation,
          reason: 'Regular wellness exams are important for preventive care',
          priority: recommendation.contains('Overdue') 
              ? SuggestionPriority.urgent 
              : SuggestionPriority.high,
          source: SuggestionSource.veterinarySchedule,
          petId: pet.id,
          actionType: 'schedule_vet_visit',
          actionData: {
            'reason': 'Wellness exam',
            'type': 'checkup',
          },
        ));
      }
    } catch (e) {
      // Health records not available, skip
    }
    
    return suggestions;
  }

  /// Generate weather-based activity suggestions
  static List<SmartSuggestion> _generateWeatherSuggestions(Pet pet) {
    final List<SmartSuggestion> suggestions = [];
    
    // Simulate weather data (in production, integrate with weather API)
    final temperature = 22.0; // Default moderate temperature
    final condition = 'clear';
    
    final weatherAdvice = PetCareKnowledgeBase.getWeatherBasedActivity(
      temperature,
      condition,
      pet.species ?? 'Unknown',
    );
    
    if (weatherAdvice.contains('Too hot') || weatherAdvice.contains('Very cold')) {
      suggestions.add(SmartSuggestion(
        type: SuggestionType.weather,
        title: 'Weather Alert for ${pet.name}',
        description: weatherAdvice,
        reason: 'Current weather conditions require special care',
        priority: SuggestionPriority.high,
        source: SuggestionSource.weather,
        petId: pet.id,
        expiresAt: DateTime.now().add(const Duration(hours: 12)),
        actionType: 'adjust_schedule',
      ));
    } else if (weatherAdvice.contains('Perfect weather')) {
      suggestions.add(SmartSuggestion(
        type: SuggestionType.exercise,
        title: 'Great Weather for ${pet.name}!',
        description: weatherAdvice,
        reason: 'Ideal conditions for outdoor activities',
        priority: SuggestionPriority.low,
        source: SuggestionSource.weather,
        petId: pet.id,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        actionType: 'plan_activity',
      ));
    }
    
    return suggestions;
  }

  /// Generate milestone-based suggestions
  static List<SmartSuggestion> _generateMilestoneSuggestions(Pet pet) {
    final List<SmartSuggestion> suggestions = [];
    final ageInMonths = pet.age * 12;
    
    // Birthday reminder
    if (ageInMonths % 12 == 0 && ageInMonths > 0) {
      suggestions.add(SmartSuggestion(
        type: SuggestionType.milestone,
        title: '${pet.name}\'s Birthday Approaching!',
        description: '${pet.name} is turning ${pet.age} years old soon',
        reason: 'Celebrate this special milestone',
        priority: SuggestionPriority.low,
        source: SuggestionSource.ageBasedMilestone,
        petId: pet.id,
        actionType: 'create_reminder',
        actionData: {
          'title': '${pet.name}\'s Birthday',
          'category': 'other',
        },
      ));
    }
    
    return suggestions;
  }

  /// Generate exercise suggestions based on pet type and age
  static List<SmartSuggestion> _generateExerciseSuggestions(Pet pet) {
    final List<SmartSuggestion> suggestions = [];
    final species = pet.species ?? '';
    final ageInMonths = pet.age * 12;
    
    if (species.toLowerCase().contains('dog')) {
      String exerciseAdvice;
      SuggestionPriority priority;
      
      if (ageInMonths < 12) {
        exerciseAdvice = 'Puppies need 5 minutes of exercise per month of age, twice daily. Short, frequent play sessions are ideal.';
        priority = SuggestionPriority.medium;
      } else if (ageInMonths > 84) {
        exerciseAdvice = 'Senior dogs benefit from gentle, regular exercise. Shorter walks and low-impact activities recommended.';
        priority = SuggestionPriority.medium;
      } else {
        exerciseAdvice = 'Adult dogs need at least 30-60 minutes of daily exercise. Regular walks and playtime keep them healthy.';
        priority = SuggestionPriority.low;
      }
      
      suggestions.add(SmartSuggestion(
        type: SuggestionType.exercise,
        title: 'Exercise Plan for ${pet.name}',
        description: exerciseAdvice,
        reason: 'Age-appropriate exercise is essential for health',
        priority: priority,
        source: SuggestionSource.bestPractices,
        petId: pet.id,
        actionType: 'create_reminder',
        actionData: {
          'title': 'Walk ${pet.name}',
          'category': 'exercise',
        },
      ));
    }
    
    return suggestions;
  }

  /// Generate general care suggestions
  static List<SmartSuggestion> _generateGeneralSuggestions() {
    final List<SmartSuggestion> suggestions = [];
    final season = PetCareKnowledgeBase.getCurrentSeason();
    
    suggestions.add(SmartSuggestion(
      type: SuggestionType.general,
      title: 'Seasonal Reminder: ${_capitalizeFirst(season)} Care',
      description: 'Don\'t forget seasonal tasks like flea prevention and weather-appropriate care',
      reason: 'Proactive seasonal care keeps your pets healthy',
      priority: SuggestionPriority.low,
      source: SuggestionSource.seasonal,
      expiresAt: _getSeasonEndDate(season),
    ));
    
    return suggestions;
  }

  /// Helper: Get season end date
  static DateTime _getSeasonEndDate(String season) {
    final now = DateTime.now();
    switch (season) {
      case 'spring':
        return DateTime(now.year, 5, 31);
      case 'summer':
        return DateTime(now.year, 8, 31);
      case 'fall':
        return DateTime(now.year, 11, 30);
      case 'winter':
        return DateTime(now.year + 1, 2, 28);
      default:
        return now.add(const Duration(days: 90));
    }
  }

  /// Helper: Capitalize first letter
  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
