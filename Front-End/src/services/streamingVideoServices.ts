import { api } from "./api";

export async function createNewConnection(
  patient_id: string,
  pc: RTCPeerConnection
): Promise<void> {
  pc.addTransceiver("video", { direction: "recvonly" });
  pc.addTransceiver("audio", { direction: "recvonly" });

  const offer = await pc.createOffer();
  await pc.setLocalDescription(offer);

  await new Promise<void>((r) => {
    if (pc.iceGatheringState === "complete") return r();
    const check = () =>
      pc.iceGatheringState === "complete" &&
      (pc.removeEventListener("icegatheringstatechange", check), r());
    pc.addEventListener("icegatheringstatechange", check);
  });

  //MARK: Need to change test_patient to patient_id
  await api
    .post<RTCSessionDescriptionInit>(`/streaming/rooms/test_patient/viewer`, {
      sdp: pc.localDescription!.sdp,
      type: pc.localDescription!.type,
    })
    .then(async (res) => {
      console.log("SDP sent to server", pc.localDescription);
      const answerJson = res as RTCSessionDescriptionInit;
      await pc.setRemoteDescription(new RTCSessionDescription(answerJson));
    })
    .finally(() => {
      console.log("SDP sent to server", pc.localDescription);
    })
    .catch((err) => {
      console.error("Error sending SDP to server", err);
    });
}
