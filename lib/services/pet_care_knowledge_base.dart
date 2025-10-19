/// Pet care best practices knowledge base
/// Contains evidence-based recommendations for pet care
class PetCareKnowledgeBase {
  
  /// Get optimal feeding times based on pet type and age
  static List<FeedingRecommendation> getFeedingSchedule(String species, int ageInMonths) {
    final isPuppy = species.toLowerCase().contains('dog') && ageInMonths < 12;
    final isKitten = species.toLowerCase().contains('cat') && ageInMonths < 12;
    final isSenior = ageInMonths > 84; // 7 years
    
    if (isPuppy && ageInMonths < 4) {
      // Very young puppies need frequent meals
      return [
        FeedingRecommendation('07:00', '4x daily (puppy)', 'Young puppies need frequent small meals'),
        FeedingRecommendation('12:00', '4x daily (puppy)', 'Supports healthy growth'),
        FeedingRecommendation('17:00', '4x daily (puppy)', 'Maintains energy levels'),
        FeedingRecommendation('21:00', '4x daily (puppy)', 'Prevents nighttime hunger'),
      ];
    } else if (isPuppy || isKitten) {
      // Older puppies/kittens
      return [
        FeedingRecommendation('08:00', '3x daily (young)', 'Growing pets need regular meals'),
        FeedingRecommendation('14:00', '3x daily (young)', 'Supports development'),
        FeedingRecommendation('20:00', '3x daily (young)', 'Evening meal'),
      ];
    } else if (isSenior) {
      // Senior pets
      return [
        FeedingRecommendation('08:00', '2x daily (senior)', 'Easier on digestion'),
        FeedingRecommendation('18:00', '2x daily (senior)', 'Senior feeding schedule'),
      ];
    } else {
      // Adult pets
      return [
        FeedingRecommendation('08:00', '2x daily (adult)', 'Morning meal'),
        FeedingRecommendation('18:00', '2x daily (adult)', 'Evening meal'),
      ];
    }
  }

  /// Get seasonal care recommendations
  static List<SeasonalCare> getSeasonalRecommendations(String season, String species) {
    final List<SeasonalCare> recommendations = [];
    
    switch (season.toLowerCase()) {
      case 'spring':
        recommendations.addAll([
          SeasonalCare(
            'Flea & Tick Prevention',
            'Start or resume flea and tick prevention as temperatures rise',
            'Spring is when parasites become active',
            priority: 'high',
          ),
          SeasonalCare(
            'Allergy Watch',
            'Monitor for seasonal allergies (excessive scratching, watery eyes)',
            'Spring pollen can affect pets',
            priority: 'medium',
          ),
          SeasonalCare(
            'Spring Grooming',
            'Schedule grooming to manage winter coat shedding',
            'Helps with temperature regulation',
            priority: 'medium',
          ),
        ]);
        break;
        
      case 'summer':
        recommendations.addAll([
          SeasonalCare(
            'Heat Safety',
            'Avoid walks during peak heat hours (11am-3pm)',
            'Prevent heatstroke and paw burns',
            priority: 'urgent',
          ),
          SeasonalCare(
            'Flea Prevention',
            'Continue monthly flea and tick prevention',
            'Peak flea season',
            priority: 'high',
          ),
          SeasonalCare(
            'Hydration Check',
            'Ensure fresh water is always available, especially during hot days',
            'Prevent dehydration',
            priority: 'high',
          ),
          SeasonalCare(
            'Pool Safety',
            'Supervise pets near water; not all pets can swim safely',
            'Water safety is crucial',
            priority: 'medium',
          ),
        ]);
        break;
        
      case 'fall':
        recommendations.addAll([
          SeasonalCare(
            'Continue Flea Prevention',
            'Don\'t stop flea prevention too early; fleas remain active',
            'Fleas thrive in fall temperatures',
            priority: 'high',
          ),
          SeasonalCare(
            'Exercise Increase',
            'Great weather for outdoor activities and exercise',
            'Comfortable temperatures for activity',
            priority: 'medium',
          ),
          SeasonalCare(
            'Seasonal Foods Warning',
            'Keep pets away from grapes, raisins, and chocolate during holidays',
            'Common fall foods can be toxic',
            priority: 'medium',
          ),
        ]);
        break;
        
      case 'winter':
        recommendations.addAll([
          SeasonalCare(
            'Cold Weather Protection',
            'Limit outdoor time in extreme cold; consider pet clothing',
            'Hypothermia prevention',
            priority: 'high',
          ),
          SeasonalCare(
            'Paw Care',
            'Protect paws from ice, salt, and de-icers',
            'Chemical burns and irritation prevention',
            priority: 'high',
          ),
          SeasonalCare(
            'Indoor Exercise',
            'Ensure adequate indoor activity when weather limits outdoor time',
            'Maintain fitness year-round',
            priority: 'medium',
          ),
          SeasonalCare(
            'Dry Skin Care',
            'Monitor for dry skin due to indoor heating',
            'Winter air can dry skin',
            priority: 'low',
          ),
        ]);
        break;
    }
    
    return recommendations;
  }

  /// Get age-based milestone reminders
  static List<MilestoneReminder> getAgeMilestones(String species, int ageInMonths) {
    final List<MilestoneReminder> milestones = [];
    
    if (species.toLowerCase().contains('dog')) {
      if (ageInMonths >= 6 && ageInMonths < 8) {
        milestones.add(MilestoneReminder(
          'Spay/Neuter Consultation',
          'Discuss spay/neuter timing with your vet (typically 6-9 months)',
          ageInMonths,
          'Veterinary',
        ));
      }
      
      if (ageInMonths >= 8 && ageInMonths < 10) {
        milestones.add(MilestoneReminder(
          'Puppy Vaccination Series Complete',
          'Ensure all puppy vaccinations are complete',
          ageInMonths,
          'Veterinary',
        ));
      }
      
      if (ageInMonths == 12) {
        milestones.add(MilestoneReminder(
          'First Birthday Check-up',
          'Schedule annual wellness exam and transition to adult food',
          ageInMonths,
          'Veterinary',
        ));
      }
      
      if (ageInMonths >= 84 && ageInMonths < 90) { // 7 years
        milestones.add(MilestoneReminder(
          'Senior Pet Transition',
          'Transition to senior pet care; consider bi-annual vet visits',
          ageInMonths,
          'Veterinary',
        ));
      }
    } else if (species.toLowerCase().contains('cat')) {
      if (ageInMonths >= 5 && ageInMonths < 7) {
        milestones.add(MilestoneReminder(
          'Spay/Neuter Consultation',
          'Discuss spay/neuter timing with your vet (typically 5-6 months for cats)',
          ageInMonths,
          'Veterinary',
        ));
      }
      
      if (ageInMonths >= 10 && ageInMonths < 12) {
        milestones.add(MilestoneReminder(
          'Kitten Vaccination Complete',
          'Ensure all kitten vaccinations are complete',
          ageInMonths,
          'Veterinary',
        ));
      }
      
      if (ageInMonths >= 72 && ageInMonths < 78) { // 6+ years
        milestones.add(MilestoneReminder(
          'Senior Cat Care',
          'Cats 7+ are seniors; consider increased vet check-ups',
          ageInMonths,
          'Veterinary',
        ));
      }
    }
    
    return milestones;
  }

  /// Get vaccination schedule based on pet age and type
  static List<VaccinationSchedule> getVaccinationSchedule(String species, int ageInMonths) {
    final List<VaccinationSchedule> schedule = [];
    
    if (species.toLowerCase().contains('dog')) {
      if (ageInMonths < 2) {
        schedule.add(VaccinationSchedule('DHPP (Distemper)', '6-8 weeks', true));
      } else if (ageInMonths >= 2 && ageInMonths < 4) {
        schedule.add(VaccinationSchedule('DHPP Booster', '10-12 weeks', true));
        schedule.add(VaccinationSchedule('Rabies', '12-16 weeks', true));
      } else if (ageInMonths >= 4 && ageInMonths < 6) {
        schedule.add(VaccinationSchedule('DHPP Final Booster', '14-16 weeks', true));
      } else {
        schedule.add(VaccinationSchedule('Annual DHPP Booster', 'Yearly', false));
        schedule.add(VaccinationSchedule('Rabies Booster', '1-3 years', false));
      }
    } else if (species.toLowerCase().contains('cat')) {
      if (ageInMonths < 2) {
        schedule.add(VaccinationSchedule('FVRCP', '6-8 weeks', true));
      } else if (ageInMonths >= 2 && ageInMonths < 4) {
        schedule.add(VaccinationSchedule('FVRCP Booster', '10-12 weeks', true));
      } else if (ageInMonths >= 4 && ageInMonths < 6) {
        schedule.add(VaccinationSchedule('FVRCP Final + Rabies', '14-16 weeks', true));
      } else {
        schedule.add(VaccinationSchedule('Annual FVRCP', 'Yearly', false));
        schedule.add(VaccinationSchedule('Rabies Booster', '1-3 years', false));
      }
    }
    
    return schedule;
  }

  /// Get weather-based activity recommendations
  static String getWeatherBasedActivity(double temperature, String condition, String species) {
    // Temperature in Celsius
    if (temperature > 30) {
      return 'Too hot for walks! Indoor play only. Ensure plenty of water.';
    } else if (temperature > 25) {
      return 'Warm weather - walk early morning or evening only. Shorter walks recommended.';
    } else if (temperature < 0) {
      return 'Very cold! Limit outdoor time. Consider booties for paw protection.';
    } else if (temperature < 5) {
      return 'Cold weather - shorter walks, consider pet clothing for small/short-haired pets.';
    } else if (condition.toLowerCase().contains('rain')) {
      return 'Rainy day - shorter potty breaks, indoor enrichment activities recommended.';
    } else if (temperature >= 15 && temperature <= 25) {
      return 'Perfect weather for outdoor activities! Great time for longer walks and play.';
    } else {
      return 'Moderate weather - normal activity schedule is fine.';
    }
  }

  /// Get vet visit recommendations based on last visit
  static String getVetVisitRecommendation(DateTime? lastVisit, int ageInMonths, bool hasMedicalConditions) {
    if (lastVisit == null) {
      return 'No vet visit recorded. Schedule a wellness check-up soon.';
    }
    
    final daysSinceVisit = DateTime.now().difference(lastVisit).inDays;
    final isSenior = ageInMonths > 84; // 7 years
    final isPuppy = ageInMonths < 12;
    
    if (hasMedicalConditions) {
      if (daysSinceVisit > 90) {
        return 'Overdue for check-up (medical condition requires frequent monitoring)';
      } else if (daysSinceVisit > 60) {
        return 'Schedule check-up soon (medical condition monitoring)';
      }
    }
    
    if (isPuppy) {
      if (daysSinceVisit > 30) {
        return 'Puppies need frequent check-ups. Schedule visit for vaccination updates.';
      }
    } else if (isSenior) {
      if (daysSinceVisit > 180) {
        return 'Senior pets need bi-annual check-ups. Schedule wellness exam.';
      }
    } else {
      if (daysSinceVisit > 365) {
        return 'Annual wellness exam is due. Schedule vet appointment.';
      } else if (daysSinceVisit > 330) {
        return 'Annual check-up approaching. Consider scheduling soon.';
      }
    }
    
    return 'No vet visit needed at this time.';
  }

  /// Get current season based on month
  static String getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'fall';
    return 'winter';
  }
}

/// Feeding recommendation model
class FeedingRecommendation {
  final String time;
  final String schedule;
  final String reason;
  
  FeedingRecommendation(this.time, this.schedule, this.reason);
}

/// Seasonal care recommendation
class SeasonalCare {
  final String title;
  final String description;
  final String reason;
  final String priority;
  
  SeasonalCare(this.title, this.description, this.reason, {this.priority = 'medium'});
}

/// Age-based milestone
class MilestoneReminder {
  final String title;
  final String description;
  final int ageInMonths;
  final String category;
  
  MilestoneReminder(this.title, this.description, this.ageInMonths, this.category);
}

/// Vaccination schedule item
class VaccinationSchedule {
  final String vaccineName;
  final String timing;
  final bool isUrgent;
  
  VaccinationSchedule(this.vaccineName, this.timing, this.isUrgent);
}
