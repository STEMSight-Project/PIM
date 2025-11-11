import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import VideoPlayer from './index';

// Mock HTMLMediaElement methods that aren't implemented in jsdom
beforeAll(() => {
  HTMLMediaElement.prototype.play = jest.fn(() => Promise.resolve());
  HTMLMediaElement.prototype.pause = jest.fn();
  HTMLMediaElement.prototype.load = jest.fn();
  
  jest.spyOn(console, 'error').mockImplementation(() => {});
  jest.spyOn(console, 'warn').mockImplementation(() => {});
});

afterAll(() => {
  jest.restoreAllMocks();
});

describe('VideoPlayer Component', () => {
  const mockOnTimeUpdate = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Rendering', () => {
    test('renders video element when videoUrl is provided', () => {
      render(
        <VideoPlayer
          videoUrl="https://example.com/test.mp4"
          currentTimestamp={0}
        />
      );

      const video = document.querySelector('video');
      expect(video).toBeInTheDocument();
      expect(video).toHaveAttribute('src', 'https://example.com/test.mp4');
    });

    test('renders video with default test URL when videoUrl is null', () => {
      render(
        <VideoPlayer
          videoUrl={null}
          currentTimestamp={0}
        />
      );

      const video = document.querySelector('video');
      expect(video).toBeInTheDocument();
      expect(video).toHaveAttribute('src', '/test-video.mp4');
    });

    test('displays "No video available" message when src is falsy', () => {
      const originalEnv = process.env.NEXT_PUBLIC_TEST_VIDEO_URL;
      delete process.env.NEXT_PUBLIC_TEST_VIDEO_URL;

      render(
        <VideoPlayer
          videoUrl=""
          currentTimestamp={0}
        />
      );

      expect(screen.getByText('No video available')).toBeInTheDocument();

      process.env.NEXT_PUBLIC_TEST_VIDEO_URL = originalEnv;
    });

    test('displays current timestamp', () => {
      render(
        <VideoPlayer
          videoUrl="test.mp4"
          currentTimestamp={42.5}
        />
      );

      expect(screen.getByText(/Current timestamp: 42\.50 seconds/)).toBeInTheDocument();
    });

    test('video has correct attributes', () => {
      render(
        <VideoPlayer
          videoUrl="test.mp4"
          currentTimestamp={0}
        />
      );

      const video = document.querySelector('video');
      expect(video).toHaveAttribute('controls');
      expect(video).toHaveAttribute('preload', 'metadata');
      expect(video).toHaveAttribute('playsInline');
    });
  });

  describe('Timestamp Seeking', () => {
    test('seeks to timestamp when video metadata is loaded', async () => {
      const { container } = render(
        <VideoPlayer
          videoUrl="test.mp4"
          currentTimestamp={30}
        />
      );

      const video = container.querySelector('video') as HTMLVideoElement;
      
      Object.defineProperty(video, 'readyState', { value: 1, writable: true });
      fireEvent.loadedMetadata(video);

      await waitFor(() => {
        expect(video.currentTime).toBe(30);
      });
    });

    test('seeks immediately if metadata already loaded', async () => {
      const { container, rerender } = render(
        <VideoPlayer
          videoUrl="test.mp4"
          currentTimestamp={15}
        />
      );

      const video = container.querySelector('video') as HTMLVideoElement;
      Object.defineProperty(video, 'readyState', { value: 2, writable: true });
      
      // Trigger rerender with new timestamp
      rerender(
        <VideoPlayer
          videoUrl="test.mp4"
          currentTimestamp={20}
        />
      );

      await waitFor(() => {
        expect(video.currentTime).toBe(20);
      });
    });

    test('handles invalid timestamp by setting to 0', () => {
      const { container } = render(
        <VideoPlayer
          videoUrl="test.mp4"
          currentTimestamp={NaN}
        />
      );

      const video = container.querySelector('video') as HTMLVideoElement;
      Object.defineProperty(video, 'readyState', { value: 2, writable: true });

      expect(video.currentTime).toBe(0);
    });

    test('updates seek position when currentTimestamp prop changes', async () => {
      const { rerender, container } = render(
        <VideoPlayer
          videoUrl="test.mp4"
          currentTimestamp={10}
        />
      );

      const video = container.querySelector('video') as HTMLVideoElement;
      Object.defineProperty(video, 'readyState', { value: 2, writable: true });

      rerender(
        <VideoPlayer
          videoUrl="test.mp4"
          currentTimestamp={50}
        />
      );

      await waitFor(() => {
        expect(video.currentTime).toBe(50);
      });
    });

    test('cleans up loadedmetadata listener on unmount', () => {
      const { container, unmount } = render(
        <VideoPlayer
          videoUrl="test.mp4"
          currentTimestamp={30}
        />
      );

      const video = container.querySelector('video') as HTMLVideoElement;
      const removeEventListenerSpy = jest.spyOn(video, 'removeEventListener');

      unmount();

      expect(removeEventListenerSpy).toHaveBeenCalledWith('loadedmetadata', expect.any(Function));
    });
  });

  describe('Time Update Callback', () => {
    test('calls onTimeUpdate when video time updates', () => {
      const { container } = render(
        <VideoPlayer
          videoUrl="test.mp4"
          currentTimestamp={0}
          onTimeUpdate={mockOnTimeUpdate}
        />
      );

      const video = container.querySelector('video') as HTMLVideoElement;
      
      Object.defineProperty(video, 'currentTime', { value: 5.5, writable: true });
      fireEvent.timeUpdate(video);

      expect(mockOnTimeUpdate).toHaveBeenCalledWith(5.5);
    });

    test('does not crash if onTimeUpdate is not provided', () => {
      const { container } = render(
        <VideoPlayer
          videoUrl="test.mp4"
          currentTimestamp={0}
        />
      );

      const video = container.querySelector('video') as HTMLVideoElement;
      
      expect(() => {
        fireEvent.timeUpdate(video);
      }).not.toThrow();
    });

    test('calls onTimeUpdate multiple times during playback', () => {
      const { container } = render(
        <VideoPlayer
          videoUrl="test.mp4"
          currentTimestamp={0}
          onTimeUpdate={mockOnTimeUpdate}
        />
      );

      const video = container.querySelector('video') as HTMLVideoElement;
      
      Object.defineProperty(video, 'currentTime', { value: 1, writable: true });
      fireEvent.timeUpdate(video);
      
      Object.defineProperty(video, 'currentTime', { value: 2, writable: true });
      fireEvent.timeUpdate(video);
      
      Object.defineProperty(video, 'currentTime', { value: 3, writable: true });
      fireEvent.timeUpdate(video);

      expect(mockOnTimeUpdate).toHaveBeenCalledTimes(3);
      expect(mockOnTimeUpdate).toHaveBeenNthCalledWith(1, 1);
      expect(mockOnTimeUpdate).toHaveBeenNthCalledWith(2, 2);
      expect(mockOnTimeUpdate).toHaveBeenNthCalledWith(3, 3);
    });

    test('cleans up event listeners on unmount', () => {
      const { container, unmount } = render(
        <VideoPlayer
          videoUrl="test.mp4"
          currentTimestamp={0}
          onTimeUpdate={mockOnTimeUpdate}
        />
      );

      const video = container.querySelector('video') as HTMLVideoElement;
      const removeEventListenerSpy = jest.spyOn(video, 'removeEventListener');

      unmount();

      expect(removeEventListenerSpy).toHaveBeenCalledWith('timeupdate', expect.any(Function));
      expect(removeEventListenerSpy).toHaveBeenCalledWith('error', expect.any(Function));
    });
  });

  describe('Error Handling', () => {
    test('logs error when video fails to load', () => {
      const consoleErrorSpy = jest.spyOn(console, 'error');
      
      const { container } = render(
        <VideoPlayer
          videoUrl="invalid.mp4"
          currentTimestamp={0}
        />
      );

      const video = container.querySelector('video') as HTMLVideoElement;
      
      Object.defineProperty(video, 'error', {
        value: { code: 4, message: 'MEDIA_ERR_SRC_NOT_SUPPORTED' }
      });
      Object.defineProperty(video, 'currentSrc', { value: 'invalid.mp4' });
      Object.defineProperty(video, 'readyState', { value: 0 });
      Object.defineProperty(video, 'networkState', { value: 3 });
      
      fireEvent.error(video);

      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'Video error:',
        expect.objectContaining({
          src: 'invalid.mp4',
          readyState: 0,
          networkState: 3,
        })
      );
    });

    test('handles seek error gracefully', () => {
      // Verify component doesn't crash with extreme values
      expect(() => {
        render(
          <VideoPlayer
            videoUrl="test.mp4"
            currentTimestamp={Infinity}
          />
        );
      }).not.toThrow();
      
      expect(document.querySelector('video')).toBeInTheDocument();
    });
  });

  describe('Video Source Changes', () => {
    test('updates video src when videoUrl prop changes', () => {
      const { rerender, container } = render(
        <VideoPlayer
          videoUrl="video1.mp4"
          currentTimestamp={0}
        />
      );

      let video = container.querySelector('video') as HTMLVideoElement;
      expect(video).toHaveAttribute('src', 'video1.mp4');

      rerender(
        <VideoPlayer
          videoUrl="video2.mp4"
          currentTimestamp={0}
        />
      );

      video = container.querySelector('video') as HTMLVideoElement;
      expect(video).toHaveAttribute('src', 'video2.mp4');
    });

    test('resets to beginning when changing videos', async () => {
      const { rerender, container } = render(
        <VideoPlayer
          videoUrl="video1.mp4"
          currentTimestamp={50}
        />
      );

      const video = container.querySelector('video') as HTMLVideoElement;
      Object.defineProperty(video, 'readyState', { value: 2, writable: true });

      rerender(
        <VideoPlayer
          videoUrl="video2.mp4"
          currentTimestamp={0}
        />
      );

      await waitFor(() => {
        expect(video.currentTime).toBe(0);
      });
    });
  });
});