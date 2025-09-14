import { useState, useEffect, useRef } from "react";
import { motion } from "framer-motion";

export default function ScriptLog() {
  const [logs, setLogs] = useState<string[]>([]);

  const logContainerRef = useRef<HTMLUListElement>(null);

  useEffect(() => {
    if (logContainerRef.current && logContainerRef.current.scrollHeight == 0) {
      logContainerRef.current.scrollTop = logContainerRef.current.scrollHeight;
    }
  }, [logs]);

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

  return (
    <div className="flex flex-col border-l-2 border-gray-400 w-[24rem] max-w-[90vw] h-full bg-black/60 backdrop-blur-md text-white shadow-lg rounded-tl-xl p-4 space-y-3 overflow-hidden z-20">
      <div className="flex items-center justify-between border-b border-white/20 pb-2">
        <h2 className="text-lg font-semibold tracking-wide">Detection Logs</h2>
      </div>

      <motion.ul
        layout
        ref={logContainerRef}
        className="flex flex-col gap-2 text-sm overflow-y-auto pr-2 h-full"
        initial={false}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.3 }}
      >
        {logs.map((log, index) => (
          <motion.li
            key={index}
            layout
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            transition={{ duration: 0.25, ease: "easeInOut" }}
            className="bg-white/10 px-3 py-2 rounded-md shadow-sm border border-white/10"
          >
            {log}
          </motion.li>
        ))}
      </motion.ul>
    </div>
  );
}
