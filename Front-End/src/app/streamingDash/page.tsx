"use client";
import React, { useEffect, useRef, useState, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import { Maximize2 } from "lucide-react";
import Header from "@/components/Header";
import Footer from "@/components/Footer";

async function negotiateViewer(roomId: string, pc: RTCPeerConnection) {
  // ❶ Create recv-only transceiver so the SDP has "m=video recvonly"
  pc.addTransceiver("video", { direction: "recvonly" });

  const offer = await pc.createOffer();
  await pc.setLocalDescription(offer);

  // wait for ICE (single, non-trickle)
  await new Promise<void>((r) => {
    if (pc.iceGatheringState === "complete") return r();
    const check = () =>
      pc.iceGatheringState === "complete" &&
      (pc.removeEventListener("icegatheringstatechange", check), r());
    pc.addEventListener("icegatheringstatechange", check);
  });

  const res = await fetch(
    `http://127.0.0.1:8000/streaming/rooms/test_patient/viewer`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        sdp: pc.localDescription!.sdp,
        type: pc.localDescription!.type,
      }),
    }
  );

  if (!res.ok) throw new Error(await res.text());
  console.log("SDP sent to server", pc.localDescription);
  const answerJson = await res.json();
  await pc.setRemoteDescription(new RTCSessionDescription(answerJson));
}
/* ──────────────────────────────────────────────────────────────────────── */

function Page() {
  const params = useSearchParams();
  const patientId = params.get("patientId") ?? "test_patient";

  const [patient, setPatient] = useState<{
    first_name: string;
    last_name: string;
  } | null>(null);
  const [logs, setLogs] = useState<string[]>([]);
  const [show, setShow] = useState(10);

  const videoRef = useRef<HTMLVideoElement>(null);
  const pcRef = useRef<RTCPeerConnection | null>(null);

  /* fetch patient once --------------------------------------------------- */
  useEffect(() => {
    fetch(`http://127.0.0.1:8000/patients/${patientId}`)
      .then((r) => (r.ok ? r.json() : null))
      .then(setPatient)
      .catch(() => {});
  }, [patientId]);

  /* generate fake detection logs ---------------------------------------- */
  useEffect(() => {
    const timer = setInterval(() => {
      const events = [
        "Myoclonus",
        "Figure of four",
        "Fencer posture",
        "Decorticate posture",
        "Decerebrate posture",
        "Hemichorea",
        "Tremor",
        "Ballistic movements",
        "Versive head posture",
      ];
      const entry = `🟡 ${new Date().toLocaleTimeString()} – ${
        events[(Math.random() * events.length) >> 0]
      }`;
      setLogs((prev) => [entry, ...prev]);
    }, 5_000);
    return () => clearInterval(timer);
  }, []);

  useEffect(() => {
    const pc = new RTCPeerConnection({
      iceServers: [{ urls: "stun:stun.l.google.com:19302" }],
    });
    pcRef.current = pc;

    pc.ontrack = (ev) => {
      console.log("ontrack", ev);
      if (ev.track.kind === "video" && videoRef.current) {
        videoRef.current.srcObject = ev.streams[0];
      }
    };

    negotiateViewer(patientId, pc).catch(console.error);

    return () => pc.close();
  }, [patientId]);

  const containerRef = useRef<HTMLDivElement>(null);
  const toggleFS = () => {
    const el = containerRef.current;
    if (!el) return;
    document.fullscreenElement
      ? document.exitFullscreen()
      : el.requestFullscreen();
  };

  return (
    <div className="flex flex-col min-h-screen bg-black">
      <Header patientId={null} />

      <div className="flex flex-col items-center flex-grow">
        <p className="text-lg text-gray-300 my-4">
          Viewing live stream for&nbsp;
          {patient ? `${patient.first_name} ${patient.last_name}` : patientId}
        </p>

        <div
          ref={containerRef}
          className="relative w-full max-w-5xl aspect-video border-4 border-gray-700 rounded-lg overflow-hidden"
        >
          <video
            ref={videoRef}
            className="w-full h-full bg-black"
            autoPlay
            playsInline
            muted
          />

          <button
            onClick={toggleFS}
            className="absolute top-2 right-2 bg-gray-800 text-white p-2 rounded-md hover:bg-gray-700"
          >
            <Maximize2 className="w-5 h-5" />
          </button>

          <div className="absolute bottom-0 w-full backdrop-blur-md text-white p-4 text-sm max-h-48 overflow-y-auto">
            <h2 className="text-lg font-semibold">Detection Logs</h2>
            <ul className="text-xs">
              {logs.slice(0, show).map((l, i) => (
                <li key={i}>{l}</li>
              ))}
            </ul>
            {show < logs.length && (
              <button
                onClick={() => setShow(show + 10)}
                className="mt-1 text-blue-400 hover:underline"
              >
                Load more
              </button>
            )}
          </div>
        </div>
      </div>

      <Footer />
    </div>
  );
}

export default function StreamingDash() {
  return (
    <Suspense fallback={null}>
      <Page />
    </Suspense>
  );
}
