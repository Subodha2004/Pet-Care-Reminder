// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Recordatorio de Cuidado de Mascotas';

  @override
  String get homeScreenTitle => 'Recordatorio de Cuidado de Mascotas';

  @override
  String get addReminder => 'Agregar Recordatorio';

  @override
  String get searchReminders => 'Buscar tus recordatorios...';

  @override
  String get noRemindersYet => 'Aún no hay recordatorios';

  @override
  String get tapToAddFirstReminder =>
      'Toca el botón + para agregar tu primer recordatorio';

  @override
  String get keepPetHappy => '¡Mantén a tu mascota feliz y saludable!';

  @override
  String get upcomingReminders => 'Próximos Recordatorios';

  @override
  String get settings => 'Configuraciones';

  @override
  String get theme => 'Tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get system => 'Sistema';

  @override
  String get textSize => 'Tamaño del Texto';

  @override
  String get small => 'Pequeño';

  @override
  String get medium => 'Mediano';

  @override
  String get large => 'Grande';

  @override
  String get extraLarge => 'Extra Grande';

  @override
  String get highContrast => 'Modo de Alto Contraste';

  @override
  String get voiceCommands => 'Comandos de Voz';

  @override
  String get hapticFeedback => 'Retroalimentación Háptica';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get areYouSureLogout => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get snooze => 'Posponer';

  @override
  String get snoozeReminder => 'Posponer Recordatorio';

  @override
  String get minutes => 'minutos';

  @override
  String get hours => 'horas';

  @override
  String get days => 'días';

  @override
  String get smartSuggestions => 'Sugerencias Inteligentes';

  @override
  String get gamification => 'Gamificación';

  @override
  String get activityHistory => 'Historial de Actividades';

  @override
  String get viewPets => 'Ver Mascotas';

  @override
  String get quickAdd => 'Agregar Rápido';

  @override
  String get all => 'Todos';

  @override
  String get save => 'Guardar';

  @override
  String get title => 'Título';

  @override
  String get description => 'Descripción';

  @override
  String get date => 'Fecha';

  @override
  String get time => 'Hora';

  @override
  String get category => 'Categoría';

  @override
  String get recurrence => 'Recurrencia';

  @override
  String get none => 'Ninguna';

  @override
  String get daily => 'Diaria';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get yearly => 'Anual';

  @override
  String get pets => 'Mascotas';

  @override
  String get health => 'Salud';

  @override
  String get feeding => 'Alimentación';

  @override
  String get grooming => 'Aseo';

  @override
  String get exercise => 'Ejercicio';

  @override
  String get medical => 'Médico';

  @override
  String get other => 'Otro';

  @override
  String get voiceCommandButton => 'Comando de Voz';

  @override
  String get listening => 'Escuchando...';

  @override
  String get didNotUnderstand =>
      'Lo siento, no entendí eso. Por favor intenta de nuevo.';

  @override
  String addReminderVoice(Object time, Object title) {
    return 'Agregar un recordatorio para $time sobre $title';
  }

  @override
  String get accessibility => 'Accesibilidad';

  @override
  String get screenReaderSupport => 'Soporte para Lector de Pantalla';

  @override
  String get adjustableTextSizes => 'Tamaños de Texto Ajustables';

  @override
  String get rightToLeftSupport =>
      'Soporte para Idiomas de Derecha a Izquierda';
}
