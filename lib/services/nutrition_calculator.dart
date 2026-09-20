class NutritionResult {
  final double bmr;
  final double tdee;
  final double dailyCalories;
  final double protein;
  final double carbohydrates;
  final double fats;

  const NutritionResult({
    required this.bmr,
    required this.tdee,
    required this.dailyCalories,
    required this.protein,
    required this.carbohydrates,
    required this.fats,
  });
}

class NutritionCalculator {
  static NutritionResult calculate({
    required int age,
    required double height,
    required double weight,
    required String gender,
    required String activityLevel,
    required String goal,
  }) {
    // Mifflin-St Jeor equation
    double bmr;

    if (gender == 'Male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Activity multiplier
    final double activityMultiplier;

    switch (activityLevel) {
      case 'Sedentary':
        activityMultiplier = 1.2;
        break;

      case 'Lightly Active':
        activityMultiplier = 1.375;
        break;

      case 'Moderately Active':
        activityMultiplier = 1.55;
        break;

      case 'Very Active':
        activityMultiplier = 1.725;
        break;

      default:
        activityMultiplier = 1.2;
    }

    final double tdee = bmr * activityMultiplier;

    // Goal adjustment
    double dailyCalories;

    switch (goal) {
      case 'Lose Weight':
        dailyCalories = tdee - 400;
        break;

      case 'Gain Weight':
        dailyCalories = tdee + 300;
        break;

      case 'Build Muscle':
        dailyCalories = tdee + 250;
        break;

      case 'Maintain Weight':
      default:
        dailyCalories = tdee;
    }

    // Keep the project's estimated target within a reasonable range.
    dailyCalories = dailyCalories.clamp(1200, 4000);

    // Protein: 1.6 g per kg body weight
    final double protein = weight * 1.6;

    // Fat: approximately 25% of calories
    final double fats = (dailyCalories * 0.25) / 9;

    // Remaining calories are assigned to carbohydrates.
    final double proteinCalories = protein * 4;
    final double fatCalories = fats * 9;

    final double carbohydrateCalories =
        dailyCalories - proteinCalories - fatCalories;

    final double carbohydrates = carbohydrateCalories > 0
        ? carbohydrateCalories / 4
        : 0;

    return NutritionResult(
      bmr: bmr,
      tdee: tdee,
      dailyCalories: dailyCalories,
      protein: protein,
      carbohydrates: carbohydrates,
      fats: fats,
    );
  }
}
