'use client';

import React, { useState, useEffect } from 'react';
import { useSearchParams } from 'next/navigation';
import SessionReview from '@/components/session-review/SessionReview';
import Header from '@/components/Header';
import Footer from '@/components/Footer';

interface Patient {
  id: string;
  first_name: string;
  last_name: string;
}

export default function SessionReviewPage() {
  const searchParams = useSearchParams();
  const patientId = searchParams.get('patientId');

  const [patient, setPatient] = useState<Patient | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (patientId) {
      // Fetch specific patient by ID
      fetch(`http://127.0.0.1:8000/patients/${patientId}`)
        .then((response) => {
          if (!response.ok) throw new Error('Failed to fetch patient data');
          return response.json();
        })
        .then((data: Patient) => {
          setPatient(data);
          setLoading(false);
        })
        .catch((error) => {
          console.error('Error fetching patient data:', error);
          setLoading(false);
        });
    } else {
      // Fetch all patients and select one randomly
      fetch('http://127.0.0.1:8000/patients/')
        .then((response) => {
          if (!response.ok) throw new Error('Failed to fetch patients');
          return response.json();
        })
        .then((data: Patient[]) => {
          if (data.length > 0) {
            const randomPatient = data[Math.floor(Math.random() * data.length)];
            setPatient(randomPatient);
          } else {
            console.error('No patients found');
          }
          setLoading(false);
        })
        .catch((error) => {
          console.error('Error fetching patients:', error);
          setLoading(false);
        });
    }
  }, [patientId]);

  if (loading) {
    return <div>Loading...</div>;
  }

  if (!patient) {
    return <div>Patient not found.</div>;
  }

  return (
    <div className="bg-gray-50 min-h-screen">
      <Header />
      <SessionReview initialPatient={patient} />
      <Footer />
    </div>
  );
}