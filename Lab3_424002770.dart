// Lab 3: The Dart App Simulator
// System: Saad Health Clinic Appointment Tracker
// Concepts: abstract class, inheritance, mixin, async/await, try-catch

// MIXIN: reusable logging behavior shared by multiple classes
mixin ActivityLogger {
  void log(String message) {
    print('[CLINIC] $message');
  }
}

// ABSTRACT CLASS: base blueprint for anyone in the clinic
abstract class Person {
  String name;
  int age;

  Person(this.name, this.age);

  String get role; // must be defined by subclasses

  void showInfo(); // must be defined by subclasses
}

// INHERITANCE: Patient extends Person
class Patient extends Person {
  String patientId;
  String complaint;

  Patient(String name, int age, this.patientId, this.complaint)
      : super(name, age);

  @override
  String get role => 'Patient';

  @override
  void showInfo() {
    print('$role: $name, $age yrs | ID: $patientId | Complaint: $complaint');
  }
}

// INHERITANCE: Doctor extends Person
class Doctor extends Person {
  String specialty;
  bool isAvailable;

  Doctor(String name, int age, this.specialty, {this.isAvailable = true})
      : super(name, age);

  @override
  String get role => 'Doctor';

  @override
  void showInfo() {
    String status = isAvailable ? 'Available' : 'Not available';
    print('$role: Dr. $name | $specialty | $status');
  }
}

// Appointment uses the ActivityLogger mixin
class Appointment with ActivityLogger {
  final int id;
  Patient patient;
  Doctor doctor;
  String schedule;
  String status = 'Pending';

  Appointment(this.id, this.patient, this.doctor, this.schedule);

  void confirm() {
    status = 'Confirmed';
    log('Appointment #$id confirmed.');
  }

  void cancel() {
    status = 'Cancelled';
    log('Appointment #$id cancelled.');
  }

  // Extra feature: move an appointment to a new schedule
  void reschedule(String newSchedule) {
    schedule = newSchedule;
    status = 'Rescheduled';
    log('Appointment #$id moved to $newSchedule.');
  }

  void showDetails() {
    print('#$id | ${patient.name} with Dr. ${doctor.name} | $schedule | $status');
  }
}

// Main system class: also uses the ActivityLogger mixin
class ClinicManager with ActivityLogger {
  final String clinicName;
  final List<Appointment> _appointments = [];
  int _nextId = 1;

  ClinicManager(this.clinicName);

  // ASYNC: simulates loading records from a server
  Future<void> loadData() async {
    print('Loading data...');
    await Future.delayed(Duration(seconds: 2));
    print('Data loaded for $clinicName.');
  }

  // ASYNC: simulates a booking request with a delay and possible errors
  Future<Appointment> bookAppointment(
      Patient patient, Doctor doctor, String schedule) async {
    print('Booking appointment for ${patient.name}...');
    await Future.delayed(Duration(seconds: 1));

    if (!doctor.isAvailable) {
      throw Exception('Dr. ${doctor.name} is not available.');
    }
    if (schedule.trim().isEmpty) {
      throw ArgumentError('Schedule cannot be empty.');
    }

    Appointment appt = Appointment(_nextId++, patient, doctor, schedule);
    _appointments.add(appt);
    log('Appointment #${appt.id} booked.');
    return appt;
  }

  void showAllAppointments() {
    print('\n--- All Appointments at $clinicName ---');
    if (_appointments.isEmpty) {
      print('No appointments yet.');
      return;
    }
    for (Appointment a in _appointments) {
      a.showDetails();
    }
  }
}

// async main(): awaits every Future
Future<void> main() async {
  ClinicManager clinic = ClinicManager('Saad Health Clinic');

  Patient patient1 = Patient('Phoebe Castillo', 25, 'P-001', 'Fever');
  Patient patient2 = Patient('Steven Macahia', 40, 'P-002', 'Back pain');
  Doctor doctor1 = Doctor('Bandrang', 45, 'General Medicine');
  Doctor doctor2 = Doctor('Wilhelm', 50, 'Orthopedics', isAvailable: false);

  print('=== Saad Health Clinic Appointment Tracker ===');
  patient1.showInfo();
  patient2.showInfo();
  doctor1.showInfo();
  doctor2.showInfo();
  print('');

  // Normal flow: should succeed
  try {
    await clinic.loadData();
    Appointment a1 =
        await clinic.bookAppointment(patient1, doctor1, 'Nov 6, 8:30 AM');
    a1.confirm();
    a1.reschedule('Nov 7, 2:00 PM');
  } catch (e) {
    print('Error: $e');
  }

  // Error flow: doctor is unavailable, so the catch block runs
  try {
    await clinic.bookAppointment(patient2, doctor2, 'Nov 7, 1:00 PM');
  } catch (e) {
    print('Booking failed: $e');
  } finally {
    print('Booking attempt finished.');
  }
 
 
  // Error flow: doctor is unavailable, so the catch block runs
  try {
    await clinic.bookAppointment(patient2, doctor2, 'Nov 7, 1:00 PM');
  } catch (e) {
    print('Booking failed: $e');
  } finally {
    print('Booking attempt finished.');
  }

  clinic.showAllAppointments();
  print('\nProgram finished.');
}