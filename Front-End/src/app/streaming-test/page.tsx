"use client";

import { Button, Card, CardContent, CardHeader } from "@/components/ui";
import { useStreaming } from "@/hooks/useStreaming";

export default function StreamingTestPage() {
  const {
    isConnected,
    isConnecting,
    isReconnecting,
    error,
    connectionQuality,
    videoRef,
    startStreaming,
    stopStreaming,
    clearError,
    reconnect,
    userFriendlyStatus,
    canManualRetry,
  } = useStreaming();

  const patientId = "0cabaa76-b0cb-4785-ae2a-9b5e96739ae3";

  const handleStartStreaming = () => {
    startStreaming(patientId); // Backend API connection (only option now)
  };

  const handleManualRetry = () => {
    if (canManualRetry) {
      reconnect();
    }
  };

  const getConnectionStatusColor = () => {
    if (isConnecting) return "bg-yellow-500 text-white px-2 py-1 rounded text-sm";
    if (isConnected) return "bg-green-500 text-white px-2 py-1 rounded text-sm";
    if (error) return "bg-red-500 text-white px-2 py-1 rounded text-sm";
    return "bg-gray-500 text-white px-2 py-1 rounded text-sm";
  };

  const getConnectionStatusText = () => {
    if (isConnecting) return "Connecting...";
    if (isConnected) return "Connected";
    if (error) return "Error";
    return "Disconnected";
  };

  return (
    <div className="container mx-auto p-4 space-y-6">
      <Card>
        <CardHeader>
          <div className="flex items-center gap-2">
            <h1 className="text-xl font-semibold">🎥 WebRTC Streaming Test</h1>
            <span className={getConnectionStatusColor()}>
              {getConnectionStatusText()}
            </span>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <h3 className="text-lg font-semibold mb-2">📡 Connection Options</h3>
              <div className="space-y-2">
                <Button 
                  onClick={handleStartStreaming}
                  disabled={isConnecting || isConnected}
                  className="w-full"
                  variant="primary"
                >
                  🌐 Start PIM Broadcasting
                </Button>
                <Button 
                  onClick={stopStreaming}
                  disabled={!isConnecting && !isConnected}
                  className="w-full"
                  variant="destructive"
                >
                  ⏹️ Stop Streaming
                </Button>
                {canManualRetry && (
                  <Button 
                    onClick={handleManualRetry}
                    className="w-full"
                    variant="outline"
                  >
                    🔄 Retry Connection
                  </Button>
                )}
              </div>
            </div>
            
            <div>
              <h3 className="text-lg font-semibold mb-2">📊 Status</h3>
              <div className="space-y-2 text-sm">
                <div><strong>Patient ID:</strong> {patientId}</div>
                <div><strong>Connection:</strong> {getConnectionStatusText()}</div>
                {connectionQuality && (
                  <div><strong>Quality:</strong> 
                    <span className="ml-2 bg-blue-100 px-2 py-1 rounded text-xs">{connectionQuality}</span>
                  </div>
                )}
                {error && (
                  <div className="bg-red-50 border border-red-200 rounded p-2">
                    <strong className="text-red-800">Error:</strong>
                    <div className="text-red-700">{error}</div>
                    <Button 
                      size="sm" 
                      variant="outline" 
                      onClick={clearError}
                      className="mt-2"
                    >
                      Clear Error
                    </Button>
                  </div>
                )}
                {isConnecting && (
                  <div className="bg-yellow-50 border border-yellow-200 rounded p-2">
                    <div className="text-yellow-800">🔄 Establishing connection...</div>
                  </div>
                )}
                {isConnected && (
                  <div className="bg-green-50 border border-green-200 rounded p-2">
                    <div className="text-green-800">✅ Live stream active</div>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Video Player */}
          <div className="w-full">
            <h3 className="text-lg font-semibold mb-2">📺 Live Video Stream</h3>
            <div className="bg-black rounded-lg overflow-hidden relative">
              <video
                ref={videoRef}
                autoPlay
                playsInline
                muted
                className="w-full h-auto max-h-96"
                style={{ aspectRatio: "16/9" }}
              />
              {!isConnected && (
                <div className="absolute inset-0 flex items-center justify-center text-white bg-black/50">
                  <div className="text-center">
                    <div className="text-2xl mb-2">📱</div>
                    <div>No video stream</div>
                    <div className="text-sm opacity-75">Connect to see live feed</div>
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Connection Info */}
          <div>
            <h3 className="text-lg font-semibold mb-2">ℹ️ Connection Information</h3>
            <div className="bg-gray-50 border rounded p-3 text-sm space-y-1">
              <div><strong>Backend API:</strong> http://localhost:8000</div>
              <div><strong>Patient ID:</strong> {patientId}</div>
              <div><strong>Frontend Port:</strong> {typeof window !== 'undefined' ? window.location.port : 'N/A'}</div>
              {userFriendlyStatus && (
                <div><strong>Status:</strong> {userFriendlyStatus}</div>
              )}
              {isReconnecting && (
                <div className="text-orange-600"><strong>Reconnecting...</strong></div>
              )}
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}