// 通知配信: ペイロードに基づき notifications テーブルに登録
// 将来: LINE 連携
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

interface NotificationPayload {
  user_id: string;
  type: string;
  title: string;
  message: string;
  related_id?: string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204 });
  }

  try {
    const payload: NotificationPayload | NotificationPayload[] =
      await req.json();
    const client = createClient(supabaseUrl, supabaseServiceKey);

    const items = Array.isArray(payload) ? payload : [payload];

    for (const item of items) {
      await client.from("notifications").insert({
        user_id: item.user_id,
        type: item.type,
        title: item.title,
        message: item.message,
        related_id: item.related_id || null,
      });
    }

    return new Response(
      JSON.stringify({ ok: true, count: items.length }),
      { headers: { "Content-Type": "application/json" }, status: 200 }
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      headers: { "Content-Type": "application/json" },
      status: 500,
    });
  }
});
