export function timestampToSeconds(timestamp: string): number {
    const [minutes, seconds, milliseconds] = timestamp.split(":").map(Number);
    return minutes * 60 + seconds + milliseconds / 1000;
}