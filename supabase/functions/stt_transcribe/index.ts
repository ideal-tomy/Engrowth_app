// OpenAI Whisper: 音声ファイルをテキストに変換
// 入力: { audio_base64: string }
// 出力: { text: string }

const OPENAI_TRANSCRIPT_URL = "https://api.openai.com/v1/audio/transcriptions";
const MODEL = "whisper-1";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function errResponse(code: string, message: string, status: number): Response {
  return new Response(JSON.stringify({ code, message }), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
    status,
  });
}

Deno.serve(async (req) => {
  try {
    if (req.method === "OPTIONS") {
      return new Response("ok", {
        headers: { ...corsHeaders, "Content-Type": "text/plain" },
        status: 200,
      });
    }

    if (req.method !== "POST") {
      return errResponse("validation_error", "Method not allowed", 405);
    }

    const apiKey = Deno.env.get("OPENAI_API_KEY");
    if (!apiKey) {
      return errResponse("upstream_error", "OpenAI API key not configured", 502);
    }

    let body: { audio_base64?: string };
    try {
      body = (await req.json()) as { audio_base64?: string };
    } catch {
      return errResponse("validation_error", "Invalid JSON body", 400);
    }

    const b64 = body.audio_base64;
    if (typeof b64 !== "string" || b64.length === 0) {
      return errResponse("validation_error", "audio_base64 is required", 400);
    }

    let audioBytes: Uint8Array;
    try {
      audioBytes = Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
    } catch {
      return errResponse("validation_error", "Invalid base64 audio", 400);
    }

    const formData = new FormData();
    formData.append("file", new Blob([audioBytes], { type: "audio/m4a" }), "audio.m4a");
    formData.append("model", MODEL);
    formData.append("language", "en");
    formData.append("response_format", "json");

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 60000);

    const res = await fetch(OPENAI_TRANSCRIPT_URL, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
      },
      body: formData,
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    if (!res.ok) {
      const errText = await res.text();
      return errResponse(
        "upstream_error",
        `OpenAI Whisper error: ${res.status} ${errText}`,
        502
      );
    }

    const data = (await res.json()) as { text?: string };
    const text = typeof data.text === "string" ? data.text : "";

    return new Response(
      JSON.stringify({ text: text.trim() }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (e) {
    const msg = String(e);
    if (msg.includes("abort") || msg.includes("timeout")) {
      return errResponse("timeout", "OpenAI Whisper timeout", 504);
    }
    console.error("stt_transcribe error:", msg, e);
    return errResponse("upstream_error", `Internal error: ${msg}`, 502);
  }
});
