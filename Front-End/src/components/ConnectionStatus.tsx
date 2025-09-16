import { Button } from "@/components/ui";
import {
  ArrowPathIcon,
  CheckCircleIcon,
  ExclamationTriangleIcon,
  SignalIcon,
  XMarkIcon,
} from "@heroicons/react/24/outline";

interface ConnectionStatusProps {
  isConnected: boolean;
  isConnecting: boolean;
  isReconnecting: boolean;
  error: string | null;
  connectionQuality: "poor" | "fair" | "good" | "excellent" | null;
  reconnectionAttempts: number;
  maxReconnectionAttempts: number;
  reconnectionCountdown: number | null;
  reconnectionProgress: number;
  userFriendlyStatus: string | null;
  canManualRetry: boolean;
  isUserCancelledReconnection: boolean;
  onReconnect: () => void;
  onCancelReconnection: () => void;
  onStopStreaming: () => void;
}

export function ConnectionStatus({
  isConnected,
  isConnecting,
  isReconnecting,
  error,
  connectionQuality,
  reconnectionAttempts,
  maxReconnectionAttempts,
  reconnectionCountdown,
  reconnectionProgress,
  userFriendlyStatus,
  canManualRetry,
  isUserCancelledReconnection,
  onReconnect,
  onCancelReconnection,
  onStopStreaming,
}: ConnectionStatusProps) {
  const getConnectionQualityColor = (quality: string | null) => {
    switch (quality) {
      case "excellent":
        return "text-green-600 bg-green-50 border-green-200";
      case "good":
        return "text-green-600 bg-green-50 border-green-200";
      case "fair":
        return "text-yellow-600 bg-yellow-50 border-yellow-200";
      case "poor":
        return "text-red-600 bg-red-50 border-red-200";
      default:
        return "text-gray-600 bg-gray-50 border-gray-200";
    }
  };

  const getStatusIcon = () => {
    if (isConnected) {
      return <CheckCircleIcon className="h-5 w-5 text-green-600" />;
    } else if (isConnecting || isReconnecting) {
      return <ArrowPathIcon className="h-5 w-5 text-blue-600 animate-spin" />;
    } else if (error || canManualRetry) {
      return <ExclamationTriangleIcon className="h-5 w-5 text-red-600" />;
    }
    return <SignalIcon className="h-5 w-5 text-gray-400" />;
  };

  const getStatusText = () => {
    if (userFriendlyStatus) {
      return userFriendlyStatus;
    } else if (isConnected) {
      return "Connected";
    } else if (isConnecting) {
      return "Connecting...";
    } else if (isReconnecting) {
      return `Reconnecting... (${reconnectionAttempts}/${maxReconnectionAttempts})`;
    } else if (error) {
      return "Connection failed";
    }
    return "Disconnected";
  };

  return (
    <div className="space-y-4">
      {/* Main status bar */}
      <div className="flex items-center justify-between p-4 bg-white border rounded-lg shadow-sm">
        <div className="flex items-center space-x-3">
          {getStatusIcon()}
          <div>
            <p className="font-medium text-gray-900">{getStatusText()}</p>
            {connectionQuality && isConnected && (
              <p className="text-sm text-gray-500">
                Connection quality: {connectionQuality}
              </p>
            )}
          </div>
        </div>

        {/* Connection quality indicator */}
        {connectionQuality && isConnected && (
          <div
            className={`px-3 py-1 rounded-full text-sm font-medium border ${getConnectionQualityColor(
              connectionQuality
            )}`}
          >
            {connectionQuality.charAt(0).toUpperCase() +
              connectionQuality.slice(1)}
          </div>
        )}
      </div>

      {/* Reconnection progress */}
      {isReconnecting && (
        <div className="p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center space-x-2">
              <ArrowPathIcon className="h-5 w-5 text-blue-600 animate-spin" />
              <span className="font-medium text-blue-800">
                Attempting to reconnect...
              </span>
            </div>
            {reconnectionCountdown && (
              <span className="text-sm text-blue-600 font-mono">
                {reconnectionCountdown}s
              </span>
            )}
          </div>

          {/* Progress bar */}
          <div className="w-full bg-blue-200 rounded-full h-2 mb-3">
            <div
              className="bg-blue-600 h-2 rounded-full transition-all duration-300"
              style={{ width: `${reconnectionProgress}%` }}
            />
          </div>

          <div className="flex items-center justify-between text-sm">
            <span className="text-blue-700">
              Attempt {reconnectionAttempts} of {maxReconnectionAttempts}
            </span>
            <Button
              onClick={onCancelReconnection}
              variant="outline"
              size="sm"
              className="border-blue-300 text-blue-700 hover:bg-blue-100"
            >
              <XMarkIcon className="h-4 w-4 mr-1" />
              Cancel
            </Button>
          </div>
        </div>
      )}

      {/* Error state with manual retry */}
      {(error || canManualRetry) && !isReconnecting && (
        <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
          <div className="flex items-start space-x-3">
            <ExclamationTriangleIcon className="h-5 w-5 text-red-600 mt-0.5" />
            <div className="flex-1">
              <p className="font-medium text-red-800">Connection Issue</p>
              {userFriendlyStatus && (
                <p className="text-sm text-red-700 mt-1">
                  {userFriendlyStatus}
                </p>
              )}
              {error && !userFriendlyStatus && (
                <p className="text-sm text-red-700 mt-1">{error}</p>
              )}
            </div>
          </div>

          {canManualRetry && (
            <div className="mt-4 flex space-x-2">
              <Button
                onClick={onReconnect}
                size="sm"
                className="bg-blue-600 hover:bg-blue-700 text-white"
              >
                <ArrowPathIcon className="h-4 w-4 mr-1" />
                Try Again
              </Button>
              <Button
                onClick={onStopStreaming}
                variant="outline"
                size="sm"
                className="border-gray-300 text-gray-700 hover:bg-gray-50"
              >
                Stop Stream
              </Button>
            </div>
          )}
        </div>
      )}

      {/* Cancelled reconnection state */}
      {isUserCancelledReconnection && (
        <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <XMarkIcon className="h-5 w-5 text-yellow-600" />
              <span className="font-medium text-yellow-800">
                Reconnection cancelled
              </span>
            </div>
            <Button
              onClick={onReconnect}
              size="sm"
              className="bg-blue-600 hover:bg-blue-700 text-white"
            >
              <ArrowPathIcon className="h-4 w-4 mr-1" />
              Reconnect
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
