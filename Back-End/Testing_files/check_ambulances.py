"""Check what ambulances exist in the database"""
import sys
import os

# Add Back-End to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from core.common import supabase
import json

def check_ambulances():
    try:
        # Query ambulances table
        result = supabase.table('ambulances').select('id, ambulance_number, vehicle_name').execute()
        
        print("Ambulances in database:")
        print(json.dumps(result.data, indent=2))
        
        # Also check if AMB-001 exists
        amb_001 = supabase.table('ambulances').select('*').eq('ambulance_number', 'AMB-001').execute()
        print("\nAMB-001 details:")
        print(json.dumps(amb_001.data, indent=2))
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    check_ambulances()
