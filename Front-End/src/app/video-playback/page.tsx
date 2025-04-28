"use client";

import { Suspense } from "react";
import SessionReviewPage from "./SessionReview";

export default function VideoPlaybackPage() {
  return (
    <Suspense>
      <SessionReviewPage />
    </Suspense>
  );
}
