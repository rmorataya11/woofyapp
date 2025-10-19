import express from 'express';
const router = express.Router();
import profileRoutes from './profile.routes';
import petRoutes from './pet.routes';
import clinicRoutes from './clinic.routes';
import appointmentRoutes from './appointment.routes';
import medicalRecordRoutes from './medical-record.routes';
import reminderRoutes from './reminder.routes';
import symptomCheckRoutes from './symptom-check.routes';
import aiChatRoutes from './ai-chat.routes';

router.use('/profiles', profileRoutes);
router.use('/pets', petRoutes);
router.use('/clinics', clinicRoutes);
router.use('/appointments', appointmentRoutes);
router.use('/medical-records', medicalRecordRoutes);
router.use('/reminders', reminderRoutes);
router.use('/symptom-checks', symptomCheckRoutes);
router.use('/ai-chat', aiChatRoutes);

router.get('/', (res) => {
  res.json({
    success: true,
    message: 'Welcome to WooFy API!',
    version: '1.0.0',
    endpoints: {
      profiles: '/api/profiles',
      pets: '/api/pets',
      clinics: '/api/clinics',
      appointments: '/api/appointments',
      medicalRecords: '/api/medical-records',
      reminders: '/api/reminders',
      symptomChecks: '/api/symptom-checks',
      aiChat: '/api/ai-chat'
    }
  });
});

export default router;

