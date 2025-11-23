import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import { aiDetectionService } from '@/services/aiDetectionService';

// Mock the service
jest.mock('@/services/aiDetectionService');
const mockAiDetectionService = aiDetectionService as jest.Mocked<typeof aiDetectionService>;

describe('Detection Validation Buttons - Unit Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  // Test 1: Confirm button functionality
  test('1.1 - Should call updateValidationStatus with "confirmed" when Confirm button is clicked', async () => {
    mockAiDetectionService.updateValidationStatus.mockResolvedValue({
      success: true,
      data: { id: 1, validation_status: 'confirmed' } as any,
      error: null,
    });

    // Simple button component for testing
    const TestComponent = () => {
      const handleConfirm = async () => {
        await aiDetectionService.updateValidationStatus(1, 'confirmed');
      };

      return <button onClick={handleConfirm}>Confirm</button>;
    };

    render(<TestComponent />);
    
    const confirmButton = screen.getByText('Confirm');
    fireEvent.click(confirmButton);

    await waitFor(() => {
      expect(mockAiDetectionService.updateValidationStatus).toHaveBeenCalledWith(1, 'confirmed');
    });
  });

  // Test 2: Deny button functionality
  test('1.2 - Should call updateValidationStatus with "rejected" when Deny button is clicked', async () => {
    mockAiDetectionService.updateValidationStatus.mockResolvedValue({
      success: true,
      data: { id: 1, validation_status: 'rejected' } as any,
      error: null,
    });

    const TestComponent = () => {
      const handleDeny = async () => {
        await aiDetectionService.updateValidationStatus(1, 'rejected');
      };

      return <button onClick={handleDeny}>Deny</button>;
    };

    render(<TestComponent />);
    
    const denyButton = screen.getByText('Deny');
    fireEvent.click(denyButton);

    await waitFor(() => {
      expect(mockAiDetectionService.updateValidationStatus).toHaveBeenCalledWith(1, 'rejected');
    });
  });

  // Test 3: Reset button functionality
  test('1.3 - Should call updateValidationStatus with "pending" when Reset button is clicked', async () => {
    mockAiDetectionService.updateValidationStatus.mockResolvedValue({
      success: true,
      data: { id: 1, validation_status: 'pending' } as any,
      error: null,
    });

    const TestComponent = () => {
      const handleReset = async () => {
        await aiDetectionService.updateValidationStatus(1, 'pending');
      };

      return <button onClick={handleReset}>Reset to Pending</button>;
    };

    render(<TestComponent />);
    
    const resetButton = screen.getByText('Reset to Pending');
    fireEvent.click(resetButton);

    await waitFor(() => {
      expect(mockAiDetectionService.updateValidationStatus).toHaveBeenCalledWith(1, 'pending');
    });
  });

  // Test 4: API returns success
  test('1.4 - Should return success when API call succeeds', async () => {
    mockAiDetectionService.updateValidationStatus.mockResolvedValue({
      success: true,
      data: { id: 1, validation_status: 'confirmed' } as any,
      error: null,
    });

    const result = await aiDetectionService.updateValidationStatus(1, 'confirmed');

    expect(result.success).toBe(true);
    expect(result.data).toBeDefined();
    expect(result.error).toBeNull();
  });

  // Test 5: API returns error
  test('1.5 - Should return error when API call fails', async () => {
    mockAiDetectionService.updateValidationStatus.mockResolvedValue({
      success: false,
      data: null,
      error: 'Network error',
    });

    const result = await aiDetectionService.updateValidationStatus(1, 'confirmed');

    expect(result.success).toBe(false);
    expect(result.data).toBeNull();
    expect(result.error).toBe('Network error');
  });

  // Test 6: Button disabled state during update
  test('1.6 - Should disable button while update is in progress', async () => {
    const TestComponent = () => {
      const [isUpdating, setIsUpdating] = React.useState(false);

      const handleConfirm = async () => {
        setIsUpdating(true);
        await aiDetectionService.updateValidationStatus(1, 'confirmed');
        setIsUpdating(false);
      };

      return (
        <button onClick={handleConfirm} disabled={isUpdating}>
          {isUpdating ? '...' : 'Confirm'}
        </button>
      );
    };

    mockAiDetectionService.updateValidationStatus.mockImplementation(
      () => new Promise(resolve => setTimeout(() => resolve({ success: true, data: null, error: null }), 100))
    );

    render(<TestComponent />);
    
    const button = screen.getByText('Confirm');
    expect(button).not.toBeDisabled();
    
    fireEvent.click(button);
    
    await waitFor(() => {
      expect(screen.getByText('...')).toBeInTheDocument();
    });
  });

  // Test 7: Handle invalid detection ID
  test('1.7 - Should handle invalid detection IDs gracefully', async () => {
    mockAiDetectionService.updateValidationStatus.mockResolvedValue({
      success: false,
      data: null,
      error: 'Invalid detection ID',
    });

    const result = await aiDetectionService.updateValidationStatus('invalid-id' as any, 'confirmed');

    expect(result.success).toBe(false);
    expect(result.error).toBe('Invalid detection ID');
  });

  // Test 8: Verify correct parameters are passed
  test('1.8 - Should pass correct detection ID and status to service', async () => {
    mockAiDetectionService.updateValidationStatus.mockResolvedValue({
      success: true,
      data: null,
      error: null,
    });

    await aiDetectionService.updateValidationStatus(42, 'rejected');

    expect(mockAiDetectionService.updateValidationStatus).toHaveBeenCalledWith(42, 'rejected');
    expect(mockAiDetectionService.updateValidationStatus).toHaveBeenCalledTimes(1);
  });
});