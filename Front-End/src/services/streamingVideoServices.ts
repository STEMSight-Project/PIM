import { api } from "./api";

export async function createNewConnection(
  patient_id: string,
  pc: RTCPeerConnection
): Promise<void> {
  try {
    pc.addTransceiver("video", { direction: "recvonly" });
    pc.addTransceiver("audio", { direction: "recvonly" });

    const offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    await new Promise<void>((resolve) => {
      if (pc.iceGatheringState === "complete") return resolve();
      const check = () =>
        pc.iceGatheringState === "complete" &&
        (pc.removeEventListener("icegatheringstatechange", check), resolve());
      pc.addEventListener("icegatheringstatechange", check);
    });

    // Use the actual patient_id instead of hardcoded "test_patient"
    const response = await api.post<RTCSessionDescriptionInit>(
      `/streaming/rooms/${patient_id}/viewer`,
      {
        sdp: pc.localDescription!.sdp,
        type: pc.localDescription!.type,
      }
    );

    console.log("SDP sent to server", pc.localDescription);

    if (response.data) {
      await pc.setRemoteDescription(new RTCSessionDescription(response.data));
      console.log("Remote description set successfully");
    } else {
      throw new Error("No SDP answer received from server");
    }
  } catch (err) {
    console.error("Error creating streaming connection", err);
    throw err;
  }
}
